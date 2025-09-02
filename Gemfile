source "https://rubygems.org"

ruby RUBY_VERSION

# GitHub Pages meta gem controls Jekyll + approved plugin versions.
# Do NOT pin jekyll/minima/kramdown/etc separately to avoid version conflicts.
# Local-only gems (like webrick) can remain.

group :jekyll_plugins do
  gem "github-pages", require: false
end

# Needed for Ruby >= 3 when serving locally.
gem "webrick", "~> 1.9"

gem 'tzinfo-data', platforms: [:jruby]
