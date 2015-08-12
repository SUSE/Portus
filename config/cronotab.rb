env = ENV["CATALOG_CRON"] || "10.minutes"
Crono.perform(CatalogJob).every eval(env)
