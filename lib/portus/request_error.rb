# frozen_string_literal: true

module ::Portus
  # RequestError wraps any exception that might arise when performing an HTTP
  # request, and provides a common `msg` method. Moreover, all raised exceptions
  # will also be logged.
  class RequestError < StandardError
    # Given an inner exception and a message, it builds up a common error
    # message.
    def initialize(exception:, message:)
      @msg = "#{exception.class.name}: #{message}"
      Rails.logger.error @msg
    end

    def to_s
      @msg
    end
  end
end
