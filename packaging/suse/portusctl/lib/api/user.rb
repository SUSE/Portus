module Portusctl
  module API
    class User < Base
      def validate!
        case @method
        when :create
          "Unexpected ID was given!" if @id
        when :update, :delete
          "You have to provide the ID of the user." unless @id
        end
      end

      def body
        { "user" => @args }.to_json
      end

      def tail
        case @method
        when :create
          ""
        else
          super
        end
      end

      protected

      # TODO: can this be taken from grape ?
      def create_parameters
        [["username", "email", "password"], ["display_name"]].freeze
      end

      # TODO: can this be taken from grape ?
      def update_parameters
        [[], ["username", "email", "password", "display_name"]].freeze
      end
    end
  end
end
