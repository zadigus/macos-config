#!/usr/bin/env bash
#
# Make Azure CLI work behind the Cognex SSL-decrypting firewall.
#
# Two independent problems, both re-introduced by every `brew upgrade azure-cli`
# because Homebrew installs a brand-new Cellar directory with a fresh vendored
# Python and certifi bundle:
#
#   1. The firewall (CN=ssl.firewall.pc.cognex.com) re-signs TLS traffic with
#      the pc-USNA-ROOTCAP01-CA root, which is not in certifi.
#      -> "self-signed certificate in certificate chain"
#      Fix: append the Cognex CA bundle to az's certifi cacert.pem.
#
#   2. The forged leaf certificates carry no Authority Key Identifier
#      extension. Python 3.13+ enables ssl.VERIFY_X509_STRICT by default,
#      which rejects them.
#      -> "certificate verify failed: Missing Authority Key Identifier"
#      Fix: clear only the VERIFY_X509_STRICT bit. Chain validation and
#      hostname checking stay fully enabled.
#
# The hook for (2) must be a .pth file, not sitecustomize.py: Homebrew's Python
# ships its own sitecustomize.py that shadows anything in site-packages, and the
# `az` wrapper runs `python -Im azure.cli` (isolated mode). .pth files in
# site-packages are still processed in isolated mode.
#
# Idempotent. Safe to run after every brew upgrade.

set -euo pipefail

cert="${HOME}/.config/cognex/CGNX_cacert.pem"
cert_url="http://usna-wbscrptp01.pc.cognex.com/COMBINED_CERT_PACKAGE.pem"

if [[ ! -f ${cert} ]]; then
    echo "Cognex CA bundle missing, downloading it to ${cert}"
    mkdir -p "$(dirname "${cert}")"
    wget -q "${cert_url}" -O "${cert}"
fi

python="$(brew --prefix azure-cli)/libexec/bin/python"
[[ -x ${python} ]] || {
    echo "azure-cli python not found at ${python}" >&2
    exit 1
}

bundle="$("${python}" -c 'import certifi; print(certifi.where())')"
site_packages="$("${python}" -c 'import site; print(site.getsitepackages()[0])')"

# 1. corporate CA into az's certifi bundle
if grep -q CGNX-APPENDED "${bundle}"; then
    echo "CA bundle already patched: ${bundle}"
else
    cp "${bundle}" "${bundle}.orig"
    {
        printf '\n# CGNX-APPENDED Cognex corporate CA bundle\n'
        cat "${cert}"
    } >>"${bundle}"
    echo "CA bundle patched: ${bundle} (original kept as ${bundle}.orig)"
fi

# 2. relax strict X.509 verification
cat >"${site_packages}/cgnx_ssl_relax.py" <<'PY'
"""Relax Python 3.13+ strict X.509 verification for Azure CLI.

The Cognex firewall performs TLS decryption and issues leaf certificates that
lack an Authority Key Identifier extension. Python 3.13+ enables
ssl.VERIFY_X509_STRICT by default, which rejects such certificates with
"certificate verify failed: Missing Authority Key Identifier".

Only that strict extension-conformance flag is cleared. Chain verification and
hostname checking remain fully enabled.

Installed by macos-config/bin/cgnx-az-fix-ssl.sh.
"""

import ssl

_base = ssl.SSLContext.__mro__[1]  # _ssl._SSLContext
_verify_flags = _base.verify_flags

ssl.SSLContext.verify_flags = property(
    lambda self: _verify_flags.__get__(self, _base),
    lambda self, value: _verify_flags.__set__(self, value & ~ssl.VERIFY_X509_STRICT),
)
PY

printf 'import cgnx_ssl_relax\n' >"${site_packages}/zz_cgnx_ssl_relax.pth"
echo "strict-X509 relaxation installed in ${site_packages}"

# verify
flags="$("${python}" -I -c 'import ssl; print(hex(ssl.create_default_context().verify_flags))')"
echo "default verify_flags now ${flags} (VERIFY_X509_STRICT=0x20 must be clear)"
