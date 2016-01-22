# Class implementing the cli interface of portusctl
class Cli < Thor
  desc "setup", "Configure Portus"
  option :secure, type: :boolean, default: true,
    desc: "Toggle SSL usage for Portus"
  # SSL certificate options
  option "ssl-organization",
    desc:    "SSL certificate: organization",
    default: "SUSE Linux GmbH" # gensslcert -o
  option "ssl-organization-unit",
    desc:    "SSL certificate: organizational unit",
    default: "SUSE Portus example" # gensslcert -u
  option "ssl-email",
    desc:    "SSL certificate: email address of webmaster",
    default: "kontact-de@novell.com" # gensslcert -e
  option "ssl-country",
    desc:    "SSL certificate: country (two letters)",
    default: "DE" # gensslcert -c
  option "ssl-city",
    desc:    "SSL certificate: city",
    default: "Nueremberg" # gensslcert -l
  option "ssl-state",
    desc:    "SSL certificate: state",
    default: "Bayern" # gensslcert -s
  # DB options
  option "db-host", desc: "Database: host", default: "localhost"
  option "db-username", desc: "Database: username", default: "portus"
  option "db-password", desc: "Database: password", default: "portus"
  option "db-name", desc: "Database: name", default: "portus_production"
  # Registry
  option "local-registry", desc: "Configure Docker registry running locally",
    type: :boolean, default: false
  # LDAP
  option "ldap-enable", desc: "LDAP: enable", type: :boolean, default: false
  option "ldap-hostname", desc: "LDAP: server hostname"
  option "ldap-port", desc: "LDAP: server port", default: "389"
  option "ldap-base",
    desc:    "LDAP: base",
    default: "ou=users, dc=example, dc=com"
  option "ldap-guess-email",
    desc:    "LDAP: guess email address",
    type:    :boolean,
    default: false
  option "ldap-guess-email-attr",
    desc: "LDAP: attribute to use when guessing email address"
  # MAILER
  option "email-from",
    desc:    "MAIL: sender address",
    default: "portus@#{HOSTNAME}"
  option "email-name", desc: "MAIL: sender name", default: "Portus"
  option "email-reply-to",
    desc:    "MAIL: reply to address",
    default: "no-reply@#{HOSTNAME}"
  option "email-smtp-enable",
    desc:    "MAIL: use SMTP as the delivery method",
    type:    :boolean,
    default: false
  option "email-smtp-address",
    desc:    "MAIL: the address to the SMTP server",
    default: "smtp.example.com"
  option "email-smtp-port", desc: "MAIL: SMTP server port", default: "587"
  option "email-smtp-username",
    desc:    "MAIL: the user name to be used for logging in the SMTP server",
    default: "username@example.com"
  option "email-smtp-password",
    desc:    "MAIL: the password to be used for logging in the SMTP server",
    default: "password"
  option "email-smtp-domain",
    desc:    "MAIL: the domain of the SMTP server",
    default: "example.com"
  # GRAVATAR
  option "gravatar", desc: "Enable Gravatar usage", type: :boolean, default: true
  # FIRST USER
  option "first-user-admin",
    desc:    "Make the first registered user an admin",
    type:    :boolean,
    default: true

  def setup
    ensure_root
    check_setup_flags

    configure = Configurator.new(options)
    configure.apache
    configure.ssl
    configure.database_config
    registry_config = configure.registry
    configure.secrets
    configure.config_local
    configure.create_database
    configure.services

    return if options["local-registry"]

    puts "Ensure the registry running on another host is configured properly"
    puts "This is a working configuration file you might want to use:"
    puts registry_config
  end

  desc "make_admin USERNAME", "Give 'admin' role to a user"
  def make_admin(username)
    if username.nil? || username.empty?
      # This will print the list of usernames
      Runner.bundler_exec("rake", "make_admin", {})
    else
      # Rake tasks look weird when they accept parameters
      Runner.bundler_exec("rake", "make_admin[#{username}]", {})
    end
  end

  desc "rake ARGS...", "Run a rake task against Portus"
  def rake(*args)
    if args.empty?
      warn "You mush provide at least an argument"
      exit 1
    end

    Runner.bundler_exec("rake", args, {})
  end

  desc "exec ARGS...", "Run a arbitrary command via bundler exec"
  def exec(*args)
    if args.empty?
      warn "You mush provide at least an argument"
      exit 1
    end
    exec_args = []
    exec_args = args[1, args.size] if args.size > 1

    Runner.bundler_exec(args[0], exec_args, {})
  end

  desc "logs", "Collect all the logs used for debugging purposes"
  def logs(*args)
    warn "Extra arguments ignored..." unless args.empty?
    ensure_root

    Runner.produce_versions_file!
    Runner.produce_crono_log_file!
    Runner.tar_files("log/production.log", "log/crono.log", "log/versions.log")
  end

  private

  def ensure_root
    return if Process.uid == 0

    warn "Must run as root user"
    exit 1
  end

  def check_setup_flags
    return unless options["ldap-enable"] && \
        (options["ldap-hostname"].nil? || options["ldap-hostname"].empty?)

    warn "LDAP support is enabled but you didn't specify a value for ldap-hostname"
    exit 1
  end
end
