class Api::V2::EventsController < Api::BaseController

  def create
    event = JSON.parse(request.body.read)
    ap event
    head status: :accepted
  end

end
