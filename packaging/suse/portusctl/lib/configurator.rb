# Class taking care of configuring the system according to
# what the user specified on the command line
class Configurator
  def initialize(options)
    @options         = options
    @secret_key_base = SecureRandom.hex(64)
    @portus_password = SecureRandom.hex(64)
  end

  # Performs the following operation:
  #   * create vhost configuration for Portus
  #   * enable mod_passenger
  #   * enable mod_ssl only if secure option is enabled
  def apache
    TemplateWriter.process(
      "apache2_portus.conf.erb",
      "/etc/apache2/vhosts.d/portus.conf",
      binding
    )

    if @options["secure"]
      Runner.exec("a2enmod", ["ssl"])
      Runner.exec("a2enflag", ["SSL"])
    end
    Runner.exec("a2enmod", ["passenger"])
    FileUtils.chown_R("wwwrun", "www", "/srv/Portus/log")
  end

  # Performs the following operations:
  #   * create the ssl certificates if specified
  #   * check the presence of the required files
  #   * copy the certificates to the right locations
  def ssl
    if @options["ssl-gen-self-signed-certs"]
      puts "Generating private key and certificate"
      args = [
        "-C", HOSTNAME,
        "-n", HOSTNAME,
        "-o", @options["ssl-organization"],
        "-u", @options["ssl-organization-unit"],
        "-e", @options["ssl-email"],
        "-c", @options["ssl-country"],
        "-l", @options["ssl-city"],
        "-s", @options["ssl-state"]
      ]
      Runner.exec("gensslcert", args)
    end

    handle_own_certs @options["ssl-certs-dir"].chomp \
      unless @options["ssl-certs-dir"].chomp.empty?

    key_file = "/etc/apache2/ssl.key/#{HOSTNAME}-ca.key"
    crt_file = "/etc/apache2/ssl.crt/#{HOSTNAME}-ca.crt"

    missing_file(key_file) unless File.exist?(key_file)
    missing_file(crt_file) unless File.exist?(crt_file)

    FileUtils.chown("wwwrun", "www", "/etc/apache2/ssl.key")
    FileUtils.chmod(0o750, "/etc/apache2/ssl.key")

    FileUtils.chown("wwwrun", "www", key_file)
    FileUtils.chmod(0o440, key_file)

    # Create key used by Portus to sign the JWT tokens
    FileUtils.ln_sf(
      key_file,
      File.join("/srv/Portus/config", "server.key")
    )

    FileUtils.cp(
      crt_file,
      "/srv/www/htdocs"
    )
    FileUtils.chmod(0o755, "/srv/www/htdocs/#{HOSTNAME}-ca.crt")
    FileUtils.cp(
      crt_file,
      "/etc/pki/trust/anchors"
    )
    Runner.exec("update-ca-certificates")
  end

  # Creates the database.yml file required by Rails
  def database_config
    TemplateWriter.process(
      "database.yml.erb",
      "/srv/Portus/config/database.yml",
      binding
    )
    FileUtils.chown("root", "www", "/srv/Portus/config/database.yml")
    FileUtils.chmod(0o640, "/srv/Portus/config/database.yml")
  end

  # Creates the database and performs the migrations
  def create_database
    if dockerized?
      puts "Running inside of a docker container"
      puts "No systemd support, skipping mysql configuration"
      return
    end

    Runner.activate_service("mysql") if database_local?

    env_variables = {
      "SKIP_MIGRATION"  => "yes",
      "PORTUS_PASSWORD" => @portus_password
    }
    puts "Creating Portus' database"
    Runner.bundler_exec("rake", ["db:create"], env_variables)

    puts "Running database migrations"
    Runner.bundler_exec("rake", ["db:migrate"], env_variables)

    puts "Seeding database"
    begin
      Runner.bundler_exec("rake", ["db:seed"], env_variables)
    rescue
      puts "Something went wrong while seedeing the database"
      puts "Are you sure the database is empty?"
      puts "Ignoring error"
    end
  end

  # Creates registry's configuration
  def registry
    if @options["local-registry"]
      # Add the certificated used by Portus to sign the JWT tokens
      ssldir = "/etc/registry/ssl.crt"
      FileUtils.mkdir_p(ssldir)
      FileUtils.ln_sf(
        "/etc/apache2/ssl.crt/#{HOSTNAME}-ca.crt",
        File.join(ssldir, "portus.crt")
      )

      TemplateWriter.process(
        "registry.yml.erb",
        "/etc/registry/config.yml",
        binding
      )
    else
      TemplateWriter.render("registry.yml.erb", binding)
    end
  end

  # Creates the config-local.yml file used by Portus
  def config_local
    if Process.uid != 0
      warn "Apache configuration must run as root user"
      exit 1
    end

    TemplateWriter.process(
      "config-local.yml.erb",
      "/srv/Portus/config/config-local.yml",
      binding
    )
    FileUtils.chown("root", "www", "/srv/Portus/config/config-local.yml")
    FileUtils.chmod(0o640, "/srv/Portus/config/config-local.yml")
  end

  # Creates the secrets.yml file used by Rails
  def secrets
    destination = "/srv/Portus/config/secrets.yml"
    return if File.exist?(destination)
    TemplateWriter.process(
      "secrets.yml.erb",
      destination,
      binding
    )
    FileUtils.chown("root", "www", destination)
    FileUtils.chmod(0o640, destination)
  end

  # Ensures all the required services are running
  def services
    if dockerized?
      puts "Running inside of a docker container"
      puts "No systemd support, skipping service activation"
      return
    end

    # portusctl runs as root and creates this file for the 1st time, so
    # we must fix its permissions
    FileUtils.chown_R("root", "www", "/srv/Portus/log/production.log")
    FileUtils.chmod_R(0o664, "/srv/Portus/log/production.log")

    services = [
      ["portus_crono", false],
      ["apache2", true]
    ]
    services << ["mysql", false] if database_local?
    services << ["registry", true] if @options["local-registry"]
    services.each do |service|
      Runner.activate_service(service[0], service[1])
    end
  end

  private

  def database_local?
    @options["db-host"] == "localhost" || @options["db-host"] == HOSTNAME
  end
end
