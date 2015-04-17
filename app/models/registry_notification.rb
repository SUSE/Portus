RELEVANT_ACTIONS = %w(push)

class RegistryEvent
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def action
    @data['action']
  end

  def process!
  end

  def relevant?
    false
  end
end

class RegistryPushEvent < RegistryEvent
  def process!
    return unless relevant?
    Image.handle_push_event(@data)
  end

  def relevant?
    @data['target']['url'].include?('manifest')
  end
end


class RegistryNotification
  attr_reader :events

  def initialize(data)
    @events = find_relevant_events(data)
  end

  def process!
    @events.each { |e| e.process! }
  end

  private

  def find_relevant_events(data)
    data['events'].
      find_all { |e| RELEVANT_ACTIONS.include?(e['action']) }.
      map{ |e| Object.const_get("Registry#{e['action'].classify}Event").new(e) }.
      find_all { |e| e.relevant? }
  end

end
