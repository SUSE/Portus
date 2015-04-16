class Api::V2::EventsController < Api::BaseController

  def create
    event = JSON.parse(request.body.read)
    push_events = event['events'].find_all do |e|
      e['action'] == 'push' && e['target']['url'].include?('manifest')
    end
    push_events.each {|e| Image.handle_push_event(e)}
    head status: :accepted
  end

end
