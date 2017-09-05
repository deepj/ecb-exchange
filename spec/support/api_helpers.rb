# frozen_string_literal: true

require 'app'

module APIHelpers
  def app
    App
  end

  def json_response
    @_json_response ||= JSON.parse(last_response.body, symbolize_names: true)
  end
end
