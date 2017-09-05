# frozen_string_literal: true

RSpec::Matchers.define :have_body do
  match do |response|
    response&.body.nil?
  end

  failure_message do
    'expected the response have a body, but it did not'
  end

  failure_message_when_negated do
    'expected the response not to have a body but it did'
  end

  description do
    'respond with a body'
  end
end
