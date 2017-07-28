module Portus
  # Handle an event as given by the Registry and processes it so it can be
  # consumed later on.
  class RegistryNotification
    # An array with the events that a handler has to support.
    HANDLED_EVENTS = ["push", "delete"].freeze

    # Processes the notification data with the given handlers. The data is the
    # parsed JSON body as given by the registry. A handler is a class that can
    # call the `handle_#{event}_event` method. This method receives an `event`
    # object, which is the event object as given by the registry.
    def self.process!(data)
      data["events"].each do |event|
        Rails.logger.debug "Incoming event:\n#{JSON.pretty_generate(event)}"

        # Skipp irrelevant or already-handled events.
        next unless should_handle?(event)

        # Only register relevant events.
        if HANDLED_EVENTS.include? event["action"]
          RegistryEvent.create!(
            event_id: event["id"],
            data:     event.to_json,
            handled:  :fresh
          )
        end

        # Depending on the configuration, the event will be handled right now,
        # or in the background by someone else.
        next if APP_CONFIG["registry"]["fetch_info_in_background"].enabled?
        RegistryEvent.handle!(event)
      end
    end

    # Returns true if the event should be handled by the according
    # handler. Otherwise, it logs why it shouldn't be handled and returns false.
    def self.should_handle?(event)
      unless relevant?(event)
        Rails.logger.debug "Event discarded because it's not relevant"
        return false
      end

      action = event["action"]
      unless HANDLED_EVENTS.include?(action)
        Rails.logger.debug "Unsupported '#{action}' event (supported: #{HANDLED_EVENTS})"
        return false
      end

      if RegistryEvent.exists?(event_id: event["id"])
        Rails.logger.debug "Event is already being processed. Ignoring..."
        false
      else
        true
      end
    end

    # A relevant event is one that contains the "push" action, and that
    # contains a Manifest v1 object in the target.
    def self.relevant?(event)
      unless event["target"].is_a?(Hash)
        Rails.logger.debug "Wrong format for event"
        return false
      end

      return true if event["action"] == "delete"

      mt = event["target"]["mediaType"]
      if mt.starts_with? "application/vnd.docker.distribution.manifest"
        true
      else
        Rails.logger.debug "Unsupported mediaType '#{mt}'"
        false
      end
    end
  end
end
