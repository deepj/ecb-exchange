# frozen_string_literal: true

$LOAD_PATH.push(__dir__)

ENV['RACK_ENV']       ||= 'development'
ENV['BUNDLE_GEMFILE'] ||= File.join(__dir__, 'Gemfile')

require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'])

require_relative 'db'

require 'irb' if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'

Dir[File.join(__dir__, 'globals', '**', '*.rb')].reverse_each(&method(:require))
