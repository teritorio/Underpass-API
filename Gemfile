# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

gem 'hanami-api'

gem 'overpass_parser', git: 'https://github.com/teritorio/overpass_parser-rb.git'
gem 'pg'
gem 'sorbet-runtime'

group :development do
  gem 'rake'
  gem 'rubocop', require: false
  gem 'rubocop-rake', require: false
  gem 'ruby-lsp', require: false
  gem 'sorbet'
  gem 'tapioca', require: false
  gem 'test-unit'

  # Only for sorbet typechecker
  gem 'psych'
  gem 'racc'
  gem 'rbi'
end

group :test do
  gem 'minitest'
end
