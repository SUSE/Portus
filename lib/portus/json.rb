module Portus
  # A safe version of the ::JSON class. This class catches exceptions and logs
  # them properly. This class assumes that the given object is a
  # request/response.
  class JSON
    # Parses the body of the given request/response. Any exception is catched
    # by this application and it's properly logged.
    #
    # Returns the given parsed JSON object on success, nil otherwise.
    def self.parse(obj)
      # Depending on whether this is a request or a response, the body will be
      # a string or an object that responds to :read.
      body = obj.body.is_a?(String) ? obj.body : obj.body.read
      ::JSON.parse(body)
    rescue ::JSON::ParserError => e
      Rails.logger.warn "JSON: parser error!"
      ::Portus::JSON.detailed_error(obj, body, e)
    rescue => e
      Rails.logger.warn "JSON: Something went wrong!"
      ::Portus::JSON.detailed_error(obj, body, e)
    end

    # Logs detailed information about what went wrong with the parsing of the
    # given JSON code.
    def self.detailed_error(obj, body, e)
      Rails.logger.warn "The following exception has been raised: #{e.message}"
      Rails.logger.warn "HTTP Code: #{obj.code}" if obj.respond_to? :code
      Rails.logger.warn "Body:\n#{body}\n"
      nil
    end
  end
end
