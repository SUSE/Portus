class RegistryEvent
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def action
    @data["action"]
  end

  def process!; end

  #:nocov: TODO: not implemented
  def relevant?
    false
  end
  #:nocov:
end
