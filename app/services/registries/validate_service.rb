# frozen_string_literal: true

module Registries
  class ValidateService < ::BaseValidateService
    def execute
      @registry = Registry.new(registry_params)
      @valid    = @registry.valid?
      @messages = @registry.errors.messages

      check_reachability!

      { valid: valid?, messages: messages }
    end

    private

    def registry_params
      params.reject { |key| key.to_sym == :only }
    end

    def check_reachability!
      return unless only_params.nil? || only_params.include?("hostname")

      reachable_msg = @registry.reachable?
      return if reachable_msg.blank?

      @valid = false
      @messages[:hostname] = (@messages[:hostname] || []).push(reachable_msg)
    end
  end
end
