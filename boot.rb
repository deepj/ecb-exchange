# frozen_string_literal: true

$LOAD_PATH.push(__dir__)

ENV['RACK_ENV']       ||= 'development'
ENV['BUNDLE_GEMFILE'] ||= File.join(__dir__, 'Gemfile')

require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'])

require_relative 'db'

# Settings
Dry::Validation.load_extensions(:monads)
