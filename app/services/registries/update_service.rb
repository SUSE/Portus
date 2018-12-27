# frozen_string_literal: true

module Registries
  class UpdateService < ::Registries::BaseService
    def execute
      @registry = Registry.find(params[:id])
      @messages = @registry.errors.messages
      @registry.assign_attributes(params)
      @valid = @registry.valid?

      check!
      if @valid
        @messages.merge(@registry.errors) unless @registry.save
      end

      @registry
    end

    protected

    def check!
      return unless @valid

      check_hostname!
      return unless @valid

      check_reachability! unless @force
    end

    def check_hostname!
      return if Repository.none? || params[:hostname].blank?

      @valid = false
      @messages[:hostname] = ["Registry is not empty, cannot change hostname"]
    end
  end
end
