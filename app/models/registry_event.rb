# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_events
#
#  id         :integer          not null, primary key
#  event_id   :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :integer          default("done")
#  data       :text(65535)
#

# RegistryEvent represents an event coming from the Registry. This model stores
# events that are being handled by Portus or that have been handled before. This
# way we avoid duplication of registry events
class RegistryEvent < ApplicationRecord
  HANDLERS = [Repository, Webhook].freeze

  enum status: { done: 0, progress: 1, fresh: 2 }

  # Processes the notification data with the given handlers. The data is the
  # parsed JSON body as given by the registry. A handler is a class that can
  # call the `handle_#{event}_event` method. This method receives an `event`
  # object, which is the event object as given by the registry.
  def self.handle!(event)
    RegistryEvent.where(event_id: event["id"]).update_all(status: RegistryEvent.statuses[:progress])

    action = event["action"]
    Rails.logger.info "Handling '#{event["action"]}' event:\n#{JSON.pretty_generate(event)}"

    # Delegate the handling to the known handlers.
    HANDLERS.each { |handler| handler.send("handle_#{action}_event".to_sym, event) }

    # Finally mark this event as handled, so a background job does not pick it
    # up again.
    RegistryEvent.where(event_id: event["id"]).update_all(status: RegistryEvent.statuses[:done])
  end
end
