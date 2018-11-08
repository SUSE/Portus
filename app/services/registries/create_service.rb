# frozen_string_literal: true

module Registries
  class CreateService < ::Registries::BaseService
    def execute
      @registry  = Registry.new(params)
      @valid     = @registry.valid?
      @messages  = @registry.errors.messages
      @reachable = true

      check!
      if @valid
        Namespace.update_all(registry_id: @registry.id) if @registry.save
        @valid = @registry.persisted?
      end

      @registry
    end

    protected

    def check!
      return unless @valid

      check_uniqueness!
      return unless @valid

      check_reachability! unless @force
    end

    def check_uniqueness!
      return unless Registry.any?

      @valid = false
      @messages[:uniqueness] = ["You can only create one registry"]
    end
  end
end
