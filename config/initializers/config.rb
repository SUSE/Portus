
config = File.join(Rails.root, 'config', 'config.yml')
local = File.join(Rails.root, 'config', 'config-local.yml')

app_config = YAML.load_file(config)['settings'] || {}

if File.exist?(local)
  local_config = YAML.load_file(local)['settings'] || {}

  app_config = app_config.merge(local_config) do |_, global, local|
    if global.is_a?(Hash) && local.is_a?(Hash)
      global.merge(local)
    else
      local
    end
  end
end

APP_CONFIG = app_config
