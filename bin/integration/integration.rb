# frozen_string_literal: true

require "English"
require "openssl"
require "fileutils"
require "yaml"

require "portus/cmd"
require "portus/test"

##
# Configurable variables.

SOURCE_DIR    = Rails.root.join("examples", "compose")
SOURCE_CONFIG = SOURCE_DIR.join("docker-compose.clair.yml")

##
# Auxiliar methods.

# Log the given message with the given level.
def log(level, str)
  Rails.logger.tagged(:integration) { Rails.logger.send(level.to_sym, str) }
end

# rubocop:disable Style/GlobalVars
$local = false

def rebuild!(can_remove)
  if can_remove
    unless ::Portus::Cmd.spawn("docker rmi -f #{::Portus::Test::LOCAL_IMAGE}")
      log :error, "Could not remove Docker image"
      exit 1
    end
  end

  root = Rails.root # Avoiding a bug on rubocop...
  return if ::Portus::Cmd.spawn("cd #{root} && docker build -t #{::Portus::Test::LOCAL_IMAGE} .")

  log :error, "Could not create Docker image"
  exit 1
end

# Returns the name of the local image to be used. It will remove a previous
# image and build it again if it's the first time it has to do so.
def build_local!
  return if local?
  $local = true

  exists = !`docker images -q #{::Portus::Test::LOCAL_IMAGE}`.empty?
  if exists
    return if ENV["PORTUS_INTEGRATION_BUILD_IMAGE"].to_s == "false"
  elsif ENV["PORTUS_INTEGRATION_BUILD_IMAGE"].present?
    log :warn, "Ignoring `PORTUS_INTEGRATION_BUILD_IMAGE` because image does not exist"
  end

  rebuild!(exists)
end

# Returns true if there are images built locally.
def local?
  $local
end
# rubocop:enable Style/GlobalVars

def portus_command
  ["command", "/srv/Portus/bin/integration/init"]
end

def background_command
  ["entrypoint", "/srv/Portus/bin/integration/init"]
end

# Returns the CN value for certificates.
def cn
  File.open(Rails.root.join("build", ".env")).each do |line|
    k, v = line.chomp.split("=")
    return v if k == "MACHINE_FQDN" && v
  end
end

##
# Define the image matrix.

images = ::Portus::Test::DEVELOPMENT_MATRIX.dup

ENV.fetch("PORTUS_TEST_INTEGRATION", "").split(" ").each do |obj|
  k, v = obj.split("#")
  next unless images[k.to_sym]
  images[k.to_sym] = v
end

##
# Parse the docker-compose file and output the proper one.

yml = YAML.load_file(SOURCE_CONFIG)
images.each do |service, image|
  next unless yml["services"][service.to_s]

  if image == ::Portus::Test::LOCAL_IMAGE
    build_local!

    entry, cmd = send("#{service}_command".to_sym)
    yml["services"][service.to_s][entry] = cmd
    yml["services"][service.to_s]["environment"] << "PORTUSCTL_EXEC_VENDOR=false"
    yml["services"][service.to_s]["environment"] << "PORTUS_GEM_GLOBAL=true"
  end

  yml["services"][service.to_s]["image"] = image
  yml["services"][service.to_s]["container_name"] = "integration_#{service}"
end

# Force debug level, so errors are more clear.
yml["services"]["portus"]["environment"] << "PORTUS_LOG_LEVEL=debug"
yml["services"]["background"]["environment"] << "PORTUS_LOG_LEVEL=debug"

# Add profiles.
yml["services"]["portus"]["volumes"] << "./profiles:/srv/Portus/spec/integration/profiles:ro"
yml["services"]["portus"]["volumes"] << "./helpers:/srv/Portus/spec/integration/helpers:ro"

# Remove some unneeded volumes: we don't want to persist data since we don't
# needed and it might be troublesome in successive runs.
yml["services"]["db"].delete("volumes")
yml["services"]["registry"]["volumes"] = [
  "./secrets:/secrets:ro",
  "./registry/config.yml:/etc/docker/registry/config.yml:ro"
]

# Print the result into the standard output if we are in a CI context.
puts yml.to_yaml if ENV["CI"]

##
# Create build directory and spit the output there.

FileUtils.rm_rf(Rails.root.join("build"))
FileUtils.mkdir_p(Rails.root.join("build", "secrets"), mode: 0o755)

dst = Rails.root.join("build", "docker-compose.yml")
log :info, "File to be used: #{dst}"
File.open(dst, "w+") { |f| f.write(yml.to_yaml) }

##
# Directories

log :info, "For normal execution remember to kill all processes using relevant ports"

FileUtils.cp(Rails.root.join(SOURCE_DIR, ".env"), Rails.root.join("build"))
FileUtils.cp_r(Rails.root.join(SOURCE_DIR, "registry"), Rails.root.join("build"))
FileUtils.cp_r(Rails.root.join(SOURCE_DIR, "clair"), Rails.root.join("build"))
FileUtils.cp_r(Rails.root.join("spec", "integration", "profiles"), Rails.root.join("build"))
FileUtils.cp_r(Rails.root.join("spec", "integration", "helpers"), Rails.root.join("build"))

##
# Generate secrets. Code taken from https://gist.github.com/nickyp/886884.

key = OpenSSL::PKey::RSA.new(2048)
public_key = key.public_key

subject = "/C=BE/O=Test/OU=Test/CN=#{cn}"

cert = OpenSSL::X509::Certificate.new
cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
cert.not_before = Time.zone.now
cert.not_after = Time.zone.now + 365 * 24 * 60 * 60
cert.public_key = public_key
cert.serial = 0x0
cert.version = 2

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.extensions = [
  ef.create_extension("basicConstraints", "CA:TRUE", true),
  ef.create_extension("subjectKeyIdentifier", "hash")
]
cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                       "keyid:always,issuer:always")

cert.sign key, OpenSSL::Digest::SHA1.new

secrets = Rails.root.join("build", "secrets")
File.open(secrets.join("portus.key"), "w+") { |f| f.write(key.to_pem) }
File.open(secrets.join("portus.crt"), "w+") { |f| f.write(cert.to_pem) }
