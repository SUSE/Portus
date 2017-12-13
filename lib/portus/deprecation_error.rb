# frozen_string_literal: true

module Portus
  # DeprecationError is the exception to be raised when certain functionality has been deprecated
  # in the latest version and we want to provide migration instructions
  class DeprecationError < StandardError
    def to_s
      "[DEPRECATED] " + super
    end
  end
end
