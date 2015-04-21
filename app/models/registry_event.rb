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
