module Portus
  # Handle an event as given by the Registry and processes it so it can be
  # consumed later on.
  class RegistryNotification
    # Processes the notification data with the given handler. The data is the
    # parsed JSON body as given by the registry. A handler is a class that can
    # call the `handle_push_event` method. This method receives an `event`
    # object, which is the event object as given by the registry.
    def self.process!(data, handler)
      data["events"].each do |event|
        next unless relevant?(event)
        Rails.logger.info "Handling Push event:\n#{JSON.pretty_generate(event)}"
        handler.handle_push_event(event)
      end
    end

    # A relevant event is one that contains the "push" action, and that
    # contains a Manifest v1 object in the target.
    def self.relevant?(event)
      return false unless event["action"] == "push"
      return false unless event["target"].is_a?(Hash)
      event["target"]["mediaType"].start_with? "application/vnd.docker.distribution.manifest"
    end
  end
end
