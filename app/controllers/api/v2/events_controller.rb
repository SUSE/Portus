class Api::V2::EventsController < Api::BaseController

  def create
    head status: :accepted
  end

end
