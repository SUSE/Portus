require "portus/health"

module API
  module V1
    class Health < Grape::API
      version "v1", using: :path

      resource :health do
        desc "Returns hash of metrics",
          tags:   ["health"],
          detail: "Returns general metrics on the health of the system"

        get do
          response, success = ::Portus::Health.check
          code = success ? 200 : 503
          status code
          response
        end
      end
    end
  end
end
