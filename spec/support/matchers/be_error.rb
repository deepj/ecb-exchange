# frozen_string_literal: true

RSpec::Matchers.define :be_error do
  match do |response|
    response = response.respond_to?(:body) ? JSON.parse(response.body, symbolize_names: true) : response
    check    = !response[:error].nil?

    check &&= response[:error][:message] == @message if @message
    check
  end

  failure_message do
    'expected the response is an error but it did not'
  end

  failure_message_when_negated do
    'expected the response is an error but it did'
  end

  description do
    'match the response is an error'
  end

  chain :with_message do |message|
    @message = message
  end
end
