# frozen_string_literal: true

# Module related to container's helpers stuff
module Containers
  # Checks whether it's running inside of a Docker container or not
  def self.dockerized?
    @dockerized ||= File.read("/proc/1/cgroup").include?("docker")
  end
end
