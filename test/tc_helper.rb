# frozen_string_literal: true

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end

require 'test/unit'
require "timecop"
require 'webmock/test_unit'
# require 'rspec/mocks/minitest_integration'
require 'ooxml_crypt' if RUBY_ENGINE == 'ruby'
require "axlsx"
