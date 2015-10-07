# Include this concern to validate the `name` attribute of the model according
# to the rules defined in registry/api/v2/names.go from Docker's Distribution
# project.
module NameValidator
  extend ActiveSupport::Concern

  NAME_ALLOWED_CHARS = "[a-z0-9]+(?:[._-][a-z0-9]+)*"

  included do
    key = name == "Namespace" ? "registry" : "namespace"

    validates :name,
              presence:   true,
              uniqueness: { scope: "#{key}_id" },
              length:     { maximum: 255 },
              format:     {
                with:    /\A#{NAME_ALLOWED_CHARS}+\Z/,
                message: "must match: #{NAME_ALLOWED_CHARS}"
              }
  end
end
