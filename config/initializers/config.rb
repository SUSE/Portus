
config = File.join(Rails.root, 'config', 'config.yml')
local = File.join(Rails.root, 'config', 'config-local.yml')

APP_CONFIG =
if File.exist?(local)
  YAML.load_file(local)['settings']
elsif File.exist?(config)
  YAML.load_file(config)['settings']
else
  raise StandardError, 'You need a config.yml file!'
end
