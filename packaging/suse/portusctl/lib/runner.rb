# Helper file used to run external commands
class Runner
  # Run a simple external command
  def self.exec(cmd, args = [])
    final_cmd = cmd + " " + args.map { |a| Shellwords.escape(a) }.join(" ")
    unless system(final_cmd)
      raise "Something went wrong while invoking: #{final_cmd}"
    end
  end

  # Run an external command using the bundler binary shipped with Portus' RPM
  def self.bundler_exec(cmd, args, extra_env_variables)
    Dir.chdir("/srv/Portus") do
      extra_env_variables.each do |key, value|
        ENV[key] = value
      end
      exec(BUNDLER_BIN, ["exec", cmd, *args])
    end
  end

  # Ensure a service is enabled and is running
  # Takes care of restarting the service when requested
  # by the user via the `restart` boolean parameter.
  def self.activate_service(service, restart = false)
    Runner.exec("systemctl", ["enable", service])
    Runner.exec(
      "systemctl",
      [
        restart ? "restart" : "start",
        service
      ])
  end
end
