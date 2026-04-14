#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

if ARGV.size != 2
  warn "Usage: #{$PROGRAM_NAME} CONCORD_DOCS_SRC WEBSITE_DOCS_DIR"
  exit 2
end

source_root = File.expand_path(ARGV[0])
target_root = File.expand_path(ARGV[1])

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

def default_front_matter(title)
  <<~YAML
    ---
    layout: wmt/docs
    title:  #{title}
    side-navigation: wmt/docs-navigation.html
    ---
  YAML
end

def collect_front_matter(target_root)
  front_matter = {}

  Dir.glob(File.join(target_root, "**", "*.md")).each do |path|
    existing_front_matter, = split_front_matter(File.read(path))
    front_matter[path] = existing_front_matter if existing_front_matter
  end

  front_matter
end

def target_front_matter(target_path, source_body, existing_front_matter)
  return existing_front_matter[target_path] if existing_front_matter.key?(target_path)

  default_front_matter(extract_title(source_body, target_path))
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

def render_markdown(source_path, target_path, existing_front_matter)
  body = strip_source_front_matter(File.read(source_path))
  body = replace_first_heading(body)
  body = rewrite_markdown_links(body)
  body = raw_wrap_literal_liquid(body)

  front_matter = target_front_matter(target_path, body, existing_front_matter)
  "#{front_matter}\n#{body}"
end

existing_front_matter = collect_front_matter(target_root)

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
      File.write(target_path, render_markdown(source_path, target_path, existing_front_matter))
    else
      FileUtils.cp(source_path, target_path)
    end
  end
end
