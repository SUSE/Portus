require_relative "base"

module Portusctl
  module API
    class ApplicationToken < ::Portusctl::API::Base
      def validate!
        "You have to provide the ID of the user." unless @id
      end

      def resource
        case @method
        when :delete
          "users/application_tokens"
        else
          "users"
        end
      end

      def tail
        case @method
        when :create
          "/#{@id}/application_tokens"
        when :delete
          "/#{@id}"
        else
          "/#{@id}/application_tokens"
        end
      end

      def body
        @args.to_json
      end

      def on_create_ok(resp)
        super

        if resp.body
          data = JSON.parse(resp.body)
          ["The token to be used for this application is: " + data["plain_token"]]
        else
          ["Something went wrong. Check the logs of Portus..."]
        end
      end

      protected

      # TODO: can this be taken from grape ?
      def create_parameters
        [["application"], []].freeze
      end
    end
  end
end
