# == Schema Information
#
# Table name: registry_events
#
#  id         :integer          not null, primary key
#  event_id   :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  handled    :integer          default("0")
#  data       :text(65535)
#

# RegistryEvent represents an event coming from the Registry. This model stores
# events that are being handled by Portus or that have been handled before. This
# way we avoid duplication of registry events
# TODO: update documentation
class RegistryEvent < ActiveRecord::Base
  HANDLERS = [Repository, Webhook].freeze

  # TODO: documentation
  enum status: [:done, :progress, :fresh]

  # TODO: documentation
  def self.handle!(event)
    # TODO: maybe this one should be called outside ?
    RegistryEvent.where(event_id: event["id"]).update_all(handled: RegistryEvent.statuses[:progress])

    action = event["action"]
    Rails.logger.info "Handling '#{event["action"]}' event:\n#{JSON.pretty_generate(event)}"

    # Delegate the handling to the known handlers.
    HANDLERS.each { |handler| handler.send("handle_#{action}_event".to_sym, event) }

    # Finally mark this event as handled, so a background job does not pick it
    # up again.
    RegistryEvent.where(event_id: event["id"]).update_all(handled: RegistryEvent.statuses[:done])
  end
end
