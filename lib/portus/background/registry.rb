# frozen_string_literal: true

module Portus
  module Background
    # Registry represents a task that syncs pending registry events into Portus.
    class Registry
      # Returns how many seconds has to pass between each loop for this
      # background service.
      def sleep_value
        2
      end

      # Returns always true because this does not depend on some configuration
      # options and because the `execute!` method will deal with valid rows
      # already.
      def work?
        true
      end

      def enabled?
        if APP_CONFIG("background.registry") == true
          Rails.logger.warn("WARNING: Registry is disabled!")
        else
          APP_CONFIG.enabled?("background.registry")
        end
      end

      def execute!
        RegistryEvent.where(status: RegistryEvent.statuses[:fresh]).find_each do |e|
          data = JSON.parse(e.data)
          RegistryEvent.handle!(data)
        end
      end

      def to_s
        "Registry events"
      end
    end
  end
end
