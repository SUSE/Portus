require "portus/health"

module API
  module V1
    class Health < Grape::API
      version "v1", using: :path

      desc "Ping this API", tags: ["health"], detail: "Returns 200 as a status code"
      get("_ping") { status 200 }

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
