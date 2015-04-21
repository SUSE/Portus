class RegistryNotification
  RELEVANT_ACTIONS = %w(push)

  attr_reader :events

  def initialize(data)
    @events = find_relevant_events(data)
  end

  def process!
    @events.each {|e| e.process! }
  end

  private

  def find_relevant_events(data)
    data['events']
      .find_all {|e| RegistryNotification::RELEVANT_ACTIONS.include?(e['action']) }
      .map {|e| Object.const_get("Registry#{e['action'].classify}Event").new(e) }
      .find_all {|e| e.relevant? }
  end

end
