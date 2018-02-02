# frozen_string_literal: true

require "portus/health"

module API
  module V1
    # Health implements endpoints that report on the health status of the API or
    # other components.
    class Health < Grape::API
      version "v1", using: :path

      desc "Ping this API", tags: ["health"], detail: "Returns 200 as a status code"
      get("_ping") { status 200 }

      resource :health do
        desc "Returns hash of metrics",
             entity:  API::Entities::Health,
             tags:    ["health"],
             detail:  "Returns general metrics on the health of the system",
             failure: [[503, "Some of the required services are unhealthy"]]

        get do
          response, success = ::Portus::Health.check
          code = success ? 200 : 503
          status code
          present response
        end
      end
    end
  end
end
