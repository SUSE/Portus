# frozen_string_literal: true

module Registries
  class BaseService < ::BaseService
    attr_reader :messages
    attr_accessor :force

    def valid?
      @valid
    end

    def reachable?
      @reachable
    end

    protected

    def check_reachability!
      msg = @registry.reachable?
      return if msg.blank?

      Rails.logger.info "\nRegistry not reachable:\n#{@registry.inspect}\n#{msg}\n"
      @valid = false
      @reachable = false
      @messages[:hostname] = (@messages[:hostname] || []).push(msg)
    end
  end
end
