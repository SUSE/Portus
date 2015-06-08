
path = File.join(Rails.root, 'config', 'config.yml')

APP_CONFIG =
if File.exist?(path)
  YAML.load_file(path)['settings']
else
  # If the config.yml file does not exist, go on with some defaults.
  {
    'gravatar' => true
  }
end
