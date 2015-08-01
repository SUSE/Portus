rails_env = new_resource.environment["RAILS_ENV"]
config.secret_key = '1'
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")
execute "rake assets:precompile" do
  cwd release_path
  command "bundle exec rake assets:precompile"
  environment "RAILS_ENV" => rails_env
  environment "SECRET_KEY_BASE" => config.secret_key
end
