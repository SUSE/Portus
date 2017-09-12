module Portusctl
  module Options
    module DB
      def self.included(thor)
        thor.class_eval do
          option "db-host", desc: "Database: host", default: "localhost"
          option "db-username", desc: "Database: username", default: "portus"
          option "db-password", desc: "Database: password", default: "portus"
          option "db-name", desc: "Database: name", default: "portus_production"
        end
      end
    end
  end
end
