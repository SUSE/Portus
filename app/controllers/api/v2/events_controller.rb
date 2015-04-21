class Api::V2::EventsController < Api::BaseController

  def create
    notification = RegistryNotification.new(JSON.parse(request.body.read))
    notification.process!
    head status: :accepted
  end

end
