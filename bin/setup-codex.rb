#!/usr/bin/env ruby
# Share OpenCode's repository checkouts with Codex. Run again after adding agents.
require 'fileutils'
require 'json'
require 'yaml'

opencode = File.join(Dir.home, '.config', 'opencode')
codex = ENV.fetch('CODEX_HOME', File.join(Dir.home, '.codex'))
skills = File.join(Dir.home, '.agents', 'skills')
agents = File.join(codex, 'agents')
marker = "# Managed by macos-config/bin/setup-codex.rb\n"

links = %w[superpowers skills-lmichel zadigus].map do |name|
  [File.join(opencode, 'skills', name), File.join(skills, name)]
end

# Preflight before writing anything; never replace an unrelated installation.
links.each do |source, target|
  abort "Missing skill repository: #{source}" unless File.directory?(source)
  next unless File.exist?(target) || File.symlink?(target)
  next if File.symlink?(target) && File.realpath(target) == File.realpath(source)

  abort "Existing skill installation conflicts with shared checkout: #{target}"
end

definitions = %w[cognex zadigus].flat_map do |repo|
  root = File.join(opencode, 'agents', repo)
  abort "Missing agent repository: #{root}" unless File.directory?(root)
  sources = Dir.glob(File.join(root, '*.md')).sort
  abort "No agent definitions in #{root}" if sources.empty?

  sources.map do |source|
    match = File.read(source).match(/\A---\r?\n(.*?)\r?\n---\r?\n/m)
    abort "Missing agent frontmatter: #{source}" unless match
    metadata = YAML.safe_load(match[1])
    description = metadata.fetch('description')
    name = "#{repo}-#{File.basename(source, '.md')}"
    instructions = <<~TEXT
      Before doing any work, read the complete agent instructions from #{source}.
      Follow the Markdown body as your role and workflow instructions. Resolve
      relative resource paths from #{File.dirname(source)}. The source is shared
      with OpenCode, so always read it fresh rather than relying on a cached copy.
      Ignore OpenCode-specific YAML settings: Codex inherits the parent session's
      model, tools, and permission policy. Adapt tool names to Codex equivalents.
      If the source cannot be read, report that and stop.
    TEXT
    if metadata.fetch('permission', {})['edit'] == 'deny'
      instructions += "This is a read-only agent: do not edit files.\n"
    end
    content = marker + {
      'name' => name,
      'description' => description,
      'developer_instructions' => instructions
    }.map { |key, value| "#{key} = #{JSON.generate(value)}\n" }.join
    target = File.join(agents, "#{name}.toml")
    if File.symlink?(target) || (File.exist?(target) && !File.read(target).start_with?(marker))
      abort "Existing unmanaged agent: #{target}"
    end
    [target, content]
  end
end

FileUtils.mkdir_p([skills, agents])
links.each do |source, target|
  File.symlink(source, target) unless File.symlink?(target)
end
definitions.each { |target, content| File.write(target, content) }
puts "Shared #{links.length} skill repositories; registered #{definitions.length} Codex agents."
