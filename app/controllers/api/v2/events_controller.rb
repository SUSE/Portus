# This is the endpoint being used to handle notifications from the Registry.
class Api::V2::EventsController < Api::BaseController
  # A new notification is coming, register it if valid.
  def create
    body = Portus::JSON.parse(request)
    Portus::RegistryNotification.process!(body, Repository) unless body.nil?
    head status: :accepted
  end
end
