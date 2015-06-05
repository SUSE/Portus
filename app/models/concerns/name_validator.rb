module NameValidator
  extend ActiveSupport::Concern

  NAME_ALLOWED_CHARS = 'a-z0-9\-_'

  included do
    key = name == 'Namespace' ? 'registry' : 'namespace'

    validates :name,
              presence: true,
              uniqueness: { scope: "#{key}_id" },
              format: {
                with: /\A[#{NAME_ALLOWED_CHARS}]+\Z/,
                message: 'Only allowed letters: [a-z0-9-_]' }
  end
end
