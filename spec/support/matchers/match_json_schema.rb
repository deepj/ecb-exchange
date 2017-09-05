# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |schema|
  schema_directory = File.join(__dir__, '..', 'schemas')

  match do |response|
    schema_path = "#{schema_directory}/#{schema}.json"
    response    = response.respond_to?(:body) ? response.body : response

    JSON::Validator.validate!(schema_path, response, strict: true)
  end

  failure_message do
    "expected the response to match JSON schema #{schema} but it did not"
  end

  failure_message_when_negated do
    "expected the response not to match JSON schema #{schema} but it did"
  end

  description do
    "match JSON schema #{schema}"
  end
end
