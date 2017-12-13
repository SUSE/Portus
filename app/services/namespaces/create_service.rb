# frozen_string_literal: true

module Namespaces
  class CreateService < ::BaseService
    attr_accessor :namespace

    def initialize(current_user, namespace = nil)
      @current_user = current_user
      @namespace = namespace
    end

    def execute
      return if namespace.nil?

      create_activity! if namespace.save

      namespace
    end

    private

    def create_activity!
      namespace.create_activity :create,
                                owner:      current_user,
                                parameters: { team: @namespace.team.name }
    end
  end
end
