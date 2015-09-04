
# TODO: (mssola) move this into its own file in the `lib` directory.
# TODO: (mssola) take advantage of YAML syntax for inheriting values. This way
# we could define different values for different environments (useful for
# testing).

config = File.join(Rails.root, "config", "config.yml")
local = File.join(Rails.root, "config", "config-local.yml")

app_config = YAML.load_file(config) || {}

if File.exist?(local)
  # Check for bad user input in the local config.yml file.
  local_config = YAML.load_file(local)
  if local_config.nil? || !local_config.is_a?(Hash)
    raise StandardError, "Wrong format for the config-local file!"
  end

  app_config = app_config.merge(local_config)
end

class << app_config
  # The `enabled?` method is a convenient method that checks whether a specific
  # feature is enabled or not. This method takes advantage of the convention
  # that each feature has the "enabled" key inside of it. If this key exists in
  # the checked feature, and it's set to true, then this method will return
  # true. It returns false otherwise.
  def enabled?(feature)
    return false if !self[feature] || self[feature].empty?
    self[feature]["enabled"].eql?(true)
  end
end

APP_CONFIG = app_config
