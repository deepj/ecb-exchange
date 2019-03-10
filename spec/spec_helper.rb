# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../app'

require_relative 'support/database_cleaner'
require_relative 'support/vcr'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.define_derived_metadata do |metadata|
    metadata[:aggregate_failures] = true unless metadata.key?(:aggregate_failures)
  end

  config.when_first_matching_example_defined(type: :request) do
    require 'rack/test'

    require_relative 'support/api_helpers'
    require_relative 'support/matchers/be_error'
    require_relative 'support/matchers/have_body'
    require_relative 'support/matchers/have_content_type'
    require_relative 'support/matchers/have_status_code'
    require_relative 'support/matchers/match_json_schema'

    config.include Rack::Test::Methods, type: :request
    config.include APIHelpers, type: :request
  end

  config.include Dry::Monads::Result::Mixin

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/support/examples.txt'
  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 5
  config.order = :random

  Kernel.srand config.seed
end
