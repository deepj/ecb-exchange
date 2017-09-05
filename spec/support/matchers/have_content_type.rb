# frozen_string_literal: true

RSpec::Matchers.define :have_content_type do |content_type = nil|
  match do |response|
    if content_type
      response.content_type == content_type
    else
      response.content_type.present?
    end
  end

  failure_message do |response|
    if content_type
      "expected the response to have content type #{content_type} but it was #{response.content_type}"
    else
      "expected the response to have no content type but it was #{response.content_type}"
    end
  end

  failure_message_when_negated do |response|
    if content_type
      "expected the response not to have content type #{content_type} but it was #{response.content_type}"
    else
      "expected the response to have no content type but it was #{response.content_type}"
    end
  end

  description do
    if content_type
      "respond with content type #{content_type}"
    else
      'respond with content type'
    end
  end
end
