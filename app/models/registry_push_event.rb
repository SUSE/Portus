class RegistryPushEvent < RegistryEvent
  def process!
    return unless relevant?
    Image.handle_push_event(@data)
  end

  def relevant?
    @data['target']['url'].include?('manifest')
  end
end
