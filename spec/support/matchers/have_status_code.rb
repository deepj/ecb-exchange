# frozen_string_literal: true

RSpec::Matchers.define :have_status_code do |status_code|
  match do |response|
    response.status == status_code.to_i
  end

  failure_message do |actual_status_code|
    "expected the response to have status code #{status_code} but it was #{actual_status_code.status}"
  end

  failure_message_when_negated do |actual_status_code|
    "expected the response not to have status code #{actual_status_code.status} but it did"
  end

  description do
    "respond with numeric status code #{status_code}"
  end
end
