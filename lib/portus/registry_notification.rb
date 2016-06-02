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
    def self.process!(data, *handlers)
      data["events"].each do |event|
        Rails.logger.debug "Incoming event:\n#{JSON.pretty_generate(event)}"
        next unless relevant?(event)

        action = event["action"]
        next unless HANDLED_EVENTS.include?(action)
        Rails.logger.info "Handling '#{action}' event:\n#{JSON.pretty_generate(event)}"

        handlers.each { |handler| handler.send("handle_#{action}_event".to_sym, event) }
      end
    end

    # A relevant event is one that contains the "push" action, and that
    # contains a Manifest v1 object in the target.
    def self.relevant?(event)
      return false unless event["target"].is_a?(Hash)
      return true if event["action"] == "delete"
      event["target"]["mediaType"].starts_with? "application/vnd.docker.distribution.manifest"
    end
  end
end
