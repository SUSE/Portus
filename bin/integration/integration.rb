# frozen_string_literal: true

require "English"
require "openssl"
require "fileutils"
require "yaml"

require "portus/cmd"
require "portus/test"

# Returns the file to be used for the given profile.
def compose_file
  profile = case ENV["PORTUS_INTEGRATION_PROFILE"]
            when /^ldap/
              ".ldap"
            else
              ".clair"
            end
  "docker-compose#{profile}.yml"
end

##
# Configurable variables.

SOURCE_DIR    = Rails.root.join("examples", "compose")
SOURCE_CONFIG = SOURCE_DIR.join(compose_file)

##
# Auxiliar methods.

# Log the given message with the given level.
def log(level, str)
  Rails.logger.tagged(:integration) { Rails.logger.send(level.to_sym, str) }
end

def rebuild!(can_remove)
  return if ENV["CI"]

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
  return if ENV["PORTUS_INTEGRATION_BUILD_IMAGE"].to_s == "false"

  exists = !`docker images -q #{::Portus::Test::LOCAL_IMAGE}`.empty?
  rebuild!(exists)
end

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

# Variables for the health command.
yml["services"]["portus"]["environment"] << "PORTUS_HEALTH_QUIET=1"
yml["services"]["portus"]["environment"] << "PORTUS_HEALTH_COMPONENT_1=database"
if ENV["PORTUS_INTEGRATION_PROFILE"] == "ldap"
  yml["services"]["portus"]["environment"] << "PORTUS_HEALTH_COMPONENT_2=ldap"
end

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
# Create build directory if needed and spit the output there.

FileUtils.mkdir_p(Rails.root.join("build", "secrets", "ldap"), mode: 0o755)

dst = Rails.root.join("build", compose_file)
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

##
# Certificates for LDAP
# TODO: join if possible with the ones above
# TODO: DIY

root_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
root_ca = OpenSSL::X509::Certificate.new
root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
root_ca.serial = 1
root_ca.subject = OpenSSL::X509::Name.parse "/C=DE/ST=Bayern/L=Nürnberg/O=SUSE/OU=Org/CN=ldap"
root_ca.issuer = root_ca.subject # root CA's are "self-signed"
root_ca.public_key = root_key.public_key
root_ca.not_before = Time.zone.now
root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = root_ca
ef.issuer_certificate = root_ca
root_ca.add_extension(ef.create_extension("basicConstraints", "CA:TRUE", true))
root_ca.add_extension(ef.create_extension("keyUsage", "keyCertSign, cRLSign", true))
root_ca.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
root_ca.add_extension(ef.create_extension("authorityKeyIdentifier", "keyid:always", false))
root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
ldap_secrets = Rails.root.join("build", "secrets", "ldap")
File.open(ldap_secrets.join("ca.crt"), "wb") { |f| f.print root_ca.to_pem }
File.open(ldap_secrets.join("ca.key"), "wb") { |f| f.print root_key.to_s }
File.open(ldap_secrets.join("ca.pem"), "wb") { |f| f.print(root_ca.to_pem + root_key.to_s) }

key = OpenSSL::PKey::RSA.new 2048
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 2
cert.subject = OpenSSL::X509::Name.parse "/C=DE/ST=Bayern/L=Nürnberg/O=SUSE/OU=Org/CN=ldap"
cert.issuer = root_ca.subject # root CA is the issuer
cert.public_key = key.public_key
cert.not_before = Time.zone.now
cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = root_ca
cert.add_extension(ef.create_extension("keyUsage", "digitalSignature", true))
cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
cert.add_extension(ef.create_extension("subjectAltName", "DNS:ldap", false))
cert.sign(root_key, OpenSSL::Digest::SHA256.new)

File.open(ldap_secrets.join("ldap.crt"), "wb") { |f| f.print cert.to_pem }
File.open(ldap_secrets.join("ldap.key"), "wb") { |f| f.print key.to_s }
File.open(ldap_secrets.join("ldap.pem"), "wb") { |f| f.print(cert.to_pem + key.to_s) }
