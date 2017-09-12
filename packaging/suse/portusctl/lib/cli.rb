require_relative "options/account"
require_relative "options/db"
require_relative "options/oauth"
require_relative "options/mailer"
require_relative "options/management"
require_relative "options/registry"
require_relative "options/security"
require_relative "options/ssl"

# Class implementing the cli interface of portusctl
class Cli < Thor
  check_unknown_options!

  desc "setup", "Configure Portus"
  option "secure", desc: "Toggle SSL usage for Portus", type: :boolean, default: true

  include ::Portusctl::Options::Account
  include ::Portusctl::Options::DB
  include ::Portusctl::Options::OAuth
  include ::Portusctl::Options::Mailer
  include ::Portusctl::Options::Management
  include ::Portusctl::Options::Registry
  include ::Portusctl::Options::Security
  include ::Portusctl::Options::SSL

  def setup
    ensure_root
    check_setup_flags options

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
      Runner.bundler_exec("rake", "portus:make_admin", {})
    else
      # Rake tasks look weird when they accept parameters
      Runner.bundler_exec("rake", "portus:make_admin[#{username}]", {})
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
    Runner.exec("cp", ["/var/log/apache2/error_log", File.join(PORTUS_ROOT, "log/production.log")])
    Runner.tar_files("log/production.log", "log/crono.log", "log/versions.log")
  end

  ## TODO: duplicated stuff...

  desc "get", "Fetches info for the given resource"
  def get(*args)
    if args.empty?
      puts "You have to provide a resource. Available resources:"
      ::Portusctl::API::Client.print_resources
      exit 1
    end

    client = ::Portusctl::API::Client.new
    puts client.get(args.first, args[1])
  end

  desc "create", "Create a given resource"
  def create(*args)
    if args.size < 2
      str = "You have to provide a resource. Available resources:\n"
      ::Portusctl::API::Client.RESOURCES.each { |r| str += "  - #{r}\n" }
      warn str
      exit 1
    end

    if args[1].include?("=")
      id = nil
      params = args[1..-1]
    else
      id = args[1]
      params = args[2..-1]
    end

    client = ::Portusctl::API::Client.new
    ret = client.create(args.first, id, params)
    return if ret.empty?

    ret.each { |line| puts line }
    exit 1
  end

  desc "update", "Update a given resource"
  def update(*args)
    # TODO: be more exact
    if args.size < 3
      str = "You have to provide a resource and the ID. Available resources:\n"
      ::Portusctl::API::Client.RESOURCES.each { |r| str += "  - #{r}\n" }
      warn str
      exit 1
    end

    client = ::Portusctl::API::Client.new
    puts client.update(args.first, args[1], args[2..-1])
  end

  desc "delete", "Deletes a given resource"
  def delete(*args)
    if args.size != 2
      str = "You have to provide a resource and the ID. Available resources:\n"
      ::Portusctl::API::Client.RESOURCES.each { |r| str += "  - #{r}\n" }
      warn str
      exit 1
    end

    client = ::Portusctl::API::Client.new
    puts client.delete(args.first, args[1])
  end
end
