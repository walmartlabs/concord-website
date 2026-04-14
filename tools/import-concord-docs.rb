#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "yaml"

if ARGV.size != 2
  warn "Usage: #{$PROGRAM_NAME} CONCORD_DOCS_SRC WEBSITE_DOCS_DIR"
  exit 2
end

source_root = File.expand_path(ARGV[0])
target_root = File.expand_path(ARGV[1])
front_matter_overrides_paths = [
  File.join(source_root, "website.yml"),
  File.expand_path("../website.yml", source_root)
].uniq
docs_edit_base_url = ENV.fetch("CONCORD_DOCS_EDIT_BASE_URL", "").sub(%r{/+\z}, "")

unless Dir.exist?(source_root)
  warn "Concord docs source directory does not exist: #{source_root}"
  exit 1
end

unless Dir.exist?(target_root)
  warn "Website docs directory does not exist: #{target_root}"
  exit 1
end

IMPORTS = {
  "api" => "api",
  "cli" => "cli",
  "getting-started" => "getting-started",
  "plugins" => "plugins-v2",
  "processes-v1" => "processes-v1",
  "processes-v2" => "processes-v2",
  "templates" => "templates",
  "triggers" => "triggers"
}.freeze

CLEAN_TARGETS = %w[
  api
  cli
  getting-started
  processes-v1
  processes-v2
  templates
  triggers
].freeze

def split_front_matter(content)
  return [nil, content] unless content.start_with?("---\n")

  closing = content.index("\n---\n", 4)
  return [nil, content] unless closing

  front_matter = content[0...(closing + "\n---\n".length)]
  body_start = closing + "\n---\n".length
  body = content[body_start, content.length] || ""
  [front_matter, body]
end

def extract_title(markdown, fallback_path)
  markdown.each_line do |line|
    match = line.match(/\A#\s+(.+?)\s*\z/)
    return match[1].strip if match
  end

  File.basename(fallback_path, ".md").split("-").map(&:capitalize).join(" ")
end

def default_front_matter_fields(title)
  {
    "layout" => "wmt/docs",
    "title" => title,
    "side-navigation" => "wmt/docs-navigation.html"
  }
end

def yaml_scalar(value)
  return value.to_s if value == true || value == false || value.nil?

  value.to_s.inspect
end

def render_front_matter(fields)
  lines = ["---"]
  fields.each do |key, value|
    lines << "#{key}: #{yaml_scalar(value)}"
  end
  lines << "---"
  lines.join("\n")
end

def parse_front_matter(front_matter)
  return {} unless front_matter

  YAML.load(front_matter.sub(/\A---\n/, "").sub(/\n---\n?\z/, "")) || {}
end

def collect_front_matter(target_root)
  front_matter = {}

  Dir.glob(File.join(target_root, "**", "*.md")).each do |path|
    existing_front_matter, = split_front_matter(File.read(path))
    next unless existing_front_matter

    relative_path = path.delete_prefix("#{target_root}/")
    front_matter[relative_path] = parse_front_matter(existing_front_matter)
  end

  front_matter
end

def collect_front_matter_overrides(paths)
  paths.each_with_object({}) do |path, overrides|
    next unless File.exist?(path)

    overrides.merge!(YAML.load_file(path) || {})
  end
end

def strip_source_front_matter(content)
  _front_matter, body = split_front_matter(content)
  body
end

def replace_first_heading(body)
  body.sub(/\A(\s*)#\s+.+?(\r?\n)/, "\\1# {{ page.title }}\\2")
end

def rewrite_markdown_links(body)
  body.gsub(%r{(\]\()([^\)\n]+?)\.md((?:#[^\)\n]+)?\))}, "\\1\\2.html\\3")
end

def raw_wrap_literal_liquid(body)
  body.gsub(/\{\{\s*(.+?)\s*\}\}/m) do |match|
    expression = Regexp.last_match(1).strip
    next match if expression.start_with?("site.", "page.")

    "{% raw %}{{ #{expression} }}{% endraw %}"
  end
end

def target_front_matter(target_path, source_body, existing_front_matter, front_matter_overrides, target_root, source_relative_path, docs_edit_base_url)
  target_relative_path = target_path.delete_prefix("#{target_root}/")
  fields = default_front_matter_fields(extract_title(source_body, target_path))
  fields.merge!(existing_front_matter.fetch(target_relative_path, {}))
  fields.merge!(front_matter_overrides.fetch(target_relative_path, {}))
  fields["edit_url"] = "#{docs_edit_base_url}/#{source_relative_path}" unless docs_edit_base_url.empty?
  render_front_matter(fields)
end

def render_markdown(source_path, target_path, existing_front_matter, front_matter_overrides, target_root, source_relative_path, docs_edit_base_url)
  source_body = strip_source_front_matter(File.read(source_path))
  body = replace_first_heading(source_body)
  body = rewrite_markdown_links(body)
  body = raw_wrap_literal_liquid(body)

  front_matter = target_front_matter(target_path, source_body, existing_front_matter, front_matter_overrides, target_root, source_relative_path, docs_edit_base_url)
  "#{front_matter}\n#{body}"
end

existing_front_matter = collect_front_matter(target_root)
front_matter_overrides = collect_front_matter_overrides(front_matter_overrides_paths)

CLEAN_TARGETS.each do |relative_dir|
  target_dir = File.join(target_root, relative_dir)
  FileUtils.rm_rf(target_dir)
  FileUtils.mkdir_p(target_dir)
end

IMPORTS.each do |source_dir, target_dir|
  full_source_dir = File.join(source_root, source_dir)
  next unless Dir.exist?(full_source_dir)

  Dir.glob(File.join(full_source_dir, "**", "*"), File::FNM_DOTMATCH).each do |source_path|
    next if [".", ".."].include?(File.basename(source_path))
    next if File.directory?(source_path)

    relative_path = source_path.delete_prefix("#{full_source_dir}/")
    target_path = File.join(target_root, target_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(target_path))

    if File.extname(source_path) == ".md"
      source_relative_path = File.join(source_dir, relative_path)
      File.write(target_path, render_markdown(source_path, target_path, existing_front_matter, front_matter_overrides, target_root, source_relative_path, docs_edit_base_url))
    else
      FileUtils.cp(source_path, target_path)
    end
  end
end
