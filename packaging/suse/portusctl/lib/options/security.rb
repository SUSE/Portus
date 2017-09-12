module Portusctl
  module Options
    module Security
      def self.included(thor)
        thor.class_eval do
          # Security scanning
          option "security-clair-server",
                 desc:    "The URL allowing Portus to access your CoreOS Clair server",
                 default: ""

          option "security-clair-health-port",
                 desc:    "The port in which Clair exposes the /health endpoint",
                 type:    :numeric,
                 default: 6061

          option "security-zypper-server",
                 desc:    "The URL allowing Portus to access your zypper-docker server",
                 default: ""

          option "security-dummy-server",
                 desc:    "If non-empty, then Portus will fake a 'dummy' server" \
                          " (only for development)",
                 default: ""

          # Anonymous browsing
          option "anonymous-browsing-enable",
                 desc:    "Allow anonymous users to explore public repositories",
                 type:    :boolean,
                 default: true
        end
      end
    end
  end
end
