default    = File.join(Rails.root, "config", "config.yml")
local      = ENV["PORTUS_LOCAL_CONFIG_PATH"] || File.join(Rails.root, "config", "config-local.yml")
cfg        = Portus::Config.new(default, local)
APP_CONFIG = cfg.fetch

# This method consumes the value of the FQDN from the app config if possible
# (as implement in Portus v2.1.x). Otherwise, it falls back to the current way
# of fetching it.
def fqdn
  mconf = APP_CONFIG["machine_fqdn"]
  return Rails.application.secrets.machine_fqdn if mconf.nil? || mconf["value"].blank?
  mconf["value"]
end
