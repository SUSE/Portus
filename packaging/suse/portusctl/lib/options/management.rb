module Portusctl
  module Options
    module Management
      def self.included(thor)
        thor.class_eval do
          option "change-visibility-enable",
                 desc:    "Allow users to change the visibility of their namespaces",
                 type:    :boolean,
                 default: true

          option "manage-namespace-enable",
                 desc:    "Allow users to modify their namespaces",
                 type:    :boolean,
                 default: true

          option "create-namespace-enable",
                 desc:    "Allow users to modify new namespaces",
                 type:    :boolean,
                 default: true

          option "manage-team-enable",
                 desc:    "Allow users to modify their teams",
                 type:    :boolean,
                 default: true

          option "create-team-enable",
                 desc:    "Allow users to create new teams",
                 type:    :boolean,
                 default: true
        end
      end
    end
  end
end
