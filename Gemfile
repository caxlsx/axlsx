# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :development, :test do
  gem 'kramdown'
  gem 'yard'

  if RUBY_ENGINE == 'ruby'
    gem 'ooxml_crypt'
  end

  if RUBY_VERSION >= '2.7'
    gem 'rubocop', '1.60.2'
    gem 'rubocop-minitest', '0.34.5'
    gem 'rubocop-performance', '1.20.2'
  end
end

group :test do
  gem 'rake'
  gem 'simplecov'
  gem 'test-unit'
  gem 'timecop'
  gem 'webmock'
  # gem 'rspec-mocks'
end

group :profile do
  gem 'memory_profiler'
  gem 'ruby-prof', platforms: :ruby
end
