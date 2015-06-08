
config = File.join(Rails.root, 'config', 'config.yml')
local = File.join(Rails.root, 'config', 'config-local.yml')

app_config = YAML.load_file(config)['settings'] || {}

if File.exist?(local)
  # Check for bad user input in the local config.yml file.
  local_config = YAML.load_file(local)['settings']
  if local_config.nil? || !local_config.is_a?(Hash)
    raise StandardError, 'Wrong format for the config-local file!'
  end

  app_config = app_config.merge(local_config)
end

APP_CONFIG = app_config
