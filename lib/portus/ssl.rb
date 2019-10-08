# frozen_string_literal: true

require "openssl"

module Portus
  module SSL
    class << self
      def verify_mode
        case APP_CONFIG["registry"]["openssl_verify_mode"]
        when "none"
          OpenSSL::SSL::VERIFY_NONE
        else
          OpenSSL::SSL::VERIFY_PEER
        end
      end
    end
  end
end
