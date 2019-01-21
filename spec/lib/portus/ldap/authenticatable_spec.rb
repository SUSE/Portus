# frozen_string_literal: true

require "ostruct"
require "rails_helper"

class ConnectionMock
  def initialize(n)
    @n = n
    @ary = Array.new(n, true)
  end

  def bind_as(_param)
    @n -= 1
    @n == 0
  end

  def search(_param)
    @ary.pop
    @ary
  end
end

# AuthenticatableMock is a thin layer on top of ::Portus::LDAP::Authenticatable,
# that allows you to define the request parameters. It also allows you to access
# the `session` object. Therefore, this class is designed to mock as least as
# possible.
class AuthenticatableMock < ::Portus::LDAP::Authenticatable
  attr_accessor :params, :session, :fail_message, :soft

  # Sets the request parameters and initializes the session.
  def initialize(params)
    @session      = {}
    @params       = params
    @fail_message = ""
    @soft         = true

    super
  end

  # Calls the protected `bind_options`. The parameter to be used is guessed from
  # the `params` instance variable.
  def bind_options_test(admin:)
    cfg = ::Portus::LDAP::Configuration.new(@params)
    bind_options(cfg, admin: admin)
  end

  def bind_admin_or_user_test(n)
    bind_admin_or_user(ConnectionMock.new(n), nil)
  end

  def search_admin_or_user_test(n)
    search_admin_or_user(ConnectionMock.new(n), nil)
  end

  def fail(msg)
    @fail_message = msg
    @soft         = true
  end

  # Mock the `fail!` message so we can capture it.
  def fail!(msg)
    @fail_message = msg
    @soft         = false
  end
end

# assert_guess_email uses AuthenticatableMock with the given `params` object and
# checks that the created user has the given `email`. You can also pass the
# attribute to be used as the configuration for `ldap.guess_email.attr`.
def assert_guess_email(params, email, attr = "")
  APP_CONFIG["ldap"]["guess_email"]["attr"] = attr

  lm = AuthenticatableMock.new(params)
  lm.authenticate!

  email.nil? ? expect(User.first.email).to(be_nil) : expect(User.first.email).to(eq(email))
end

describe ::Portus::LDAP::Authenticatable do
  before do
    APP_CONFIG["ldap"]["enabled"] = true
    allow_any_instance_of(described_class).to receive(:authenticate!).and_call_original
  end

  context "#adapter" do
    # Let's make code coverage happy
    it "calls the right adapter" do
      ldap = ::Portus::LDAP::Authenticatable.new(nil)
      expect(ldap.adapter.to_s).to eq "Net::LDAP"
    end
  end

  it "loads the configuration properly" do
    params = { user: { username: "name", password: "1234" } }
    ldap   = ::Portus::LDAP::Authenticatable.new(params)
    cfg    = ldap.adapter_options

    expect(cfg[:host]).to eq "hostname"
    expect(cfg[:port]).to eq 389
    expect(cfg[:encryption]).to be_nil
    expect(cfg[:auth]).to be_nil
  end

  context "encryption" do
    it "returns the proper value for each method" do
      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)

      [["starttls", :start_tls], ["simple_tls", :simple_tls]].each do |e|
        APP_CONFIG["ldap"]["encryption"]["method"] = e[0]
        cfg = ldap.adapter_options
        expect(cfg[:encryption][:method]).to eq e[1]
      end
    end

    it "returns nil on plain" do
      APP_CONFIG["ldap"]["encryption"] = { "method" => "plain" }

      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)
      cfg    = ldap.adapter_options

      expect(cfg[:encryption]).to be_nil
    end

    it "returns nil on unknown method" do
      APP_CONFIG["ldap"]["encryption"] = { "method" => "lala" }

      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)
      cfg    = ldap.adapter_options

      expect(cfg[:encryption]).to be_nil
    end

    it "returns some default parameters when options are not given" do
      APP_CONFIG["ldap"]["encryption"] = { "method" => "start_tls" }

      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)
      cfg    = ldap.adapter_options

      expect(cfg[:encryption][:method]).to eq :start_tls
      expect(cfg[:encryption][:tls_options]).to eq OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
    end

    it "adds the CA file" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method"  => "start_tls",
        "options" => { "ca_file" => "/my/pem/file" }
      }

      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)
      cfg    = ldap.adapter_options

      expect(cfg[:encryption][:method]).to eq :start_tls
      expect(cfg[:encryption][:tls_options][:ca_file]).to eq "/my/pem/file"
      expect(cfg[:encryption][:tls_options][:ssl_version]).to be_nil
    end

    it "adds the CA file and the SSL version" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method"  => "start_tls",
        "options" => { "ca_file" => "/my/pem/file", "ssl_version" => "TLSv1_1" }
      }

      params = { user: { username: "name", password: "1234" } }
      ldap   = ::Portus::LDAP::Authenticatable.new(params)
      cfg    = ldap.adapter_options

      expect(cfg[:encryption][:method]).to eq :start_tls
      expect(cfg[:encryption][:tls_options][:ca_file]).to eq "/my/pem/file"
      expect(cfg[:encryption][:tls_options][:ssl_version]).to eq "TLSv1_1"
    end
  end

  it "loads the auth configuration properly" do
    # auth configuration disabled
    auth = { "enabled" => false }
    APP_CONFIG["ldap"]["authentication"] = auth

    params = { user: { username: "name", password: "1234" } }
    ldap   = ::Portus::LDAP::Authenticatable.new(params)
    cfg    = ldap.adapter_options
    expect(cfg).not_to have_key(:auth)

    # auth configuration enabled
    auth = { "enabled" => true, "bind_dn" => "foo", "password" => "pass" }
    APP_CONFIG["ldap"]["authentication"] = auth

    ldap = ::Portus::LDAP::Authenticatable.new(params)
    cfg = ldap.adapter_options
    expect(cfg[:auth][:username]).to eq "foo"
    expect(cfg[:auth][:password]).to eq "pass"
    expect(cfg[:auth][:method]).to eq :simple
  end

  context "bind options" do
    let(:params)   { { user: { username: "name", password: "1234" } } }
    let(:instance) { AuthenticatableMock.new(params) }

    it "filters according to the given uid" do
      APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "uid" => "uid" }

      opts = instance.bind_options_test(admin: false)

      expect(opts.size).to eq 2
      expect(opts[:filter].to_s).to eq "(uid=name)"
      expect(opts[:password]).to eq "1234"
    end

    it "includes the base if given" do
      APP_CONFIG["ldap"] = {
        "enabled" => true,
        "base"    => "ou=users,dc=example,dc=com",
        "uid"     => "uid"
      }

      opts = instance.bind_options_test(admin: false)

      expect(opts.size).to eq 3
      expect(opts[:filter].to_s).to eq "(uid=name)"
      expect(opts[:password]).to eq "1234"
      expect(opts[:base]).to eq "ou=users,dc=example,dc=com"
    end

    it "the base is the admin if requested and both bases are present" do
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      opts = instance.bind_options_test(admin: true)

      expect(opts.size).to eq 3
      expect(opts[:filter].to_s).to eq "(uid=name)"
      expect(opts[:password]).to eq "1234"
      expect(opts[:base]).to eq "ou=admins,dc=example,dc=com"
    end

    it "the base is nil if requested admin but it's not provided" do
      APP_CONFIG["ldap"] = {
        "enabled" => true,
        "base"    => "ou=users,dc=example,dc=com",
        "uid"     => "uid"
      }

      opts = instance.bind_options_test(admin: true)

      expect(opts.size).to eq 3
      expect(opts[:filter].to_s).to eq "(uid=name)"
      expect(opts[:password]).to eq "1234"
      expect(opts[:base]).to be_nil
    end

    it "the base is the normal one if both were provided but the normal was requested" do
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      opts = instance.bind_options_test(admin: false)

      expect(opts.size).to eq 3
      expect(opts[:filter].to_s).to eq "(uid=name)"
      expect(opts[:password]).to eq "1234"
      expect(opts[:base]).to eq "ou=users,dc=example,dc=com"
    end

    it "the filter for the uid is properly updated" do
      APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "uid" => "foo" }

      opts = instance.bind_options_test(admin: false)

      expect(opts[:filter].to_s).to eq "(foo=name)"
    end

    it "knows how to build more complex filters" do
      APP_CONFIG["ldap"] = {
        "enabled" => true,
        "base"    => "",
        "uid"     => "foo",
        "filter"  => "mail=g*"
      }

      opts = instance.bind_options_test(admin: false)

      expect(opts[:filter].to_s).to eq "(&(foo=name)(mail=g*))"
    end
  end

  describe "#bind_admin_user" do
    let(:params)   { { user: { username: "name", password: "1234" } } }
    let(:instance) { AuthenticatableMock.new(params) }

    it "returns an admin when admin_base present" do
      allow_any_instance_of(AuthenticatableMock).to receive(:bind_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      _res, admin = instance.bind_admin_or_user_test(1)
      expect(admin).to be_truthy
    end

    it "returns an user when admin_base present but failed" do
      allow_any_instance_of(AuthenticatableMock).to receive(:bind_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      _res, admin = instance.bind_admin_or_user_test(2)
      expect(admin).to be_falsey
    end

    it "returns an user when admin_base was not set" do
      allow_any_instance_of(AuthenticatableMock).to receive(:bind_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      _res, admin = instance.bind_admin_or_user_test(1)
      expect(admin).to be_truthy
    end
  end

  describe "#search_admin_or_user" do
    let(:params)   { { user: { username: "name", password: "1234" } } }
    let(:instance) { AuthenticatableMock.new(params) }

    it "returns an admin when admin_base present" do
      allow_any_instance_of(AuthenticatableMock).to receive(:search_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      res = instance.search_admin_or_user_test(2)
      expect(res.size).to eq 1
    end

    it "returns an user when admin_base present but failed" do
      allow_any_instance_of(AuthenticatableMock).to receive(:search_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      res = instance.search_admin_or_user_test(3)
      expect(res.size).to eq 1
    end

    it "returns an user when admin_base was not set" do
      allow_any_instance_of(AuthenticatableMock).to receive(:search_options).and_return(nil)
      APP_CONFIG["ldap"] = {
        "enabled"    => true,
        "base"       => "ou=users,dc=example,dc=com",
        "admin_base" => "ou=admins,dc=example,dc=com",
        "uid"        => "uid"
      }

      res = instance.search_admin_or_user_test(2)
      expect(res.size).to eq 1
    end
  end

  describe "#find_or_create_user!" do
    let(:valid_response) do
      [
        {
          "dn"    => ["ou=users,dc=example,dc=com"],
          "email" => "user@example.com"
        }
      ]
    end

    before do
      APP_CONFIG["ldap"]["enabled"] = true

      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(true)
    end

    it "the ldap user could be located" do
      user   = create(:user, username: "name")
      params = { user: { username: "name", password: "1234" } }

      expect do
        lm = AuthenticatableMock.new(params)
        lm.authenticate!
      end.to_not(change { User.all.size })

      expect(User.first.id).to eq user.id
    end

    it "creates a new ldap user" do
      params = { user: { username: "name", password: "12341234" } }

      expect do
        lm = AuthenticatableMock.new(params)
        lm.authenticate!
      end.to change { User.all.size }.from(0).to(1)

      expect(User.find_by(username: "name")).not_to be nil
    end

    it "creates a new ldap user even if it has weird characters" do
      # Creating a registry so namespaces can be created.
      create(:registry)

      params = { user: { username: "name!o", password: "12341234" } }

      expect do
        lm = AuthenticatableMock.new(params)
        lm.authenticate!
      end.to change { User.all.size }.by(1)

      user = User.find_by(username: "name!o")
      expect(user.username).to eq "name!o"
      expect(user.namespace.name).to eq "name_o"
    end

    it "allows multiple users to have no email setup" do
      APP_CONFIG["ldap"]["guess_email"] = { "enabled" => false }

      params1 = { user: { username: "name", password: "12341234" } }
      params2 = { user: { username: "another", password: "12341234" } }

      expect do
        lm = AuthenticatableMock.new(params1)
        lm.authenticate!

        lm = AuthenticatableMock.new(params2)
        lm.authenticate!
      end.to change { User.all.size }.by(2)

      expect(User.find_by(username: "name")).to_not be_nil
      expect(User.find_by(username: "another")).to_not be_nil
    end

    it "raises the proper error on email duplication" do
      APP_CONFIG["ldap"]["base"]        = ""
      APP_CONFIG["ldap"]["guess_email"] = { "enabled" => true, "attr" => "email" }

      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(valid_response)

      params = { user: { username: "name", password: "12341234" } }
      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      params[:user][:username] = "another"
      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      [["name", "user@example.com"], ["another", nil]].each do |u|
        user = User.find_by(username: u.first)
        expect(user.email).to eq u.last
      end
    end
  end

  describe "#authenticate!" do
    before do
      ENV["LDAP_OPERATION_CODE"] = nil
      ENV["LDAP_RAISE_EXCEPTION"] = nil

      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["base"] = ""
    end

    it "fails softly if ldap is not supported" do
      APP_CONFIG["ldap"]["enabled"] = false
      params = { user: { username: "name", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      expect(lm.fail_message).to eq "LDAP is not enabled"
      expect(lm.soft).to be_truthy
    end

    it "fails hard if a LDAP-only user tried to login with LDAP disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      u = create(:user, username: "name")
      u.update!(encrypted_password: "")
      params = { user: { username: "name", password: "12341234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      expect(lm.fail_message).to eq "This user can only authenticate if LDAP is enabled"
      expect(lm.soft).to be_falsey
    end

    it "fails if the user couldn't bind" do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_raise(Net::LDAP::Error, "a message")

      params = { user: { username: "name", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      expect(lm.fail_message).to eq "a message"
      expect(lm.soft).to be_falsey
    end

    it "fails if the user was not found" do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(false)
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(
        OpenStruct.new(
          message: "not found",
          code:    0
        )
      )

      params = { user: { username: "name", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      expect(lm.fail_message).to eq "Could not find user 'name'"
    end

    it "fails when creating a user went wrong" do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(true)
      allow_any_instance_of(User).to receive(:valid?).and_return(false)
      allow_any_instance_of(User).to(
        receive(:errors)
          .and_return(OpenStruct.new(full_messages: ["error message"]))
      )

      params = { user: { username: "name", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!

      expect(lm.fail_message).to eq "error message"
    end

    it "fails 'softly' for the portus user" do
      params = { account: "portus", user: { username: "portus", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!
      expect(lm.fail_message).to eq "Portus user does not go through LDAP"
      expect(lm.soft).to be_truthy
    end

    it "fails 'softly' for bots" do
      create(:user, username: "bot", bot: true)
      params = { user: { username: "bot", password: "1234" } }

      lm = AuthenticatableMock.new(params)
      lm.authenticate!
      expect(lm.fail_message).to eq "Bot user is not expected to be present on LDAP"
      expect(lm.soft).to be_truthy
    end

    it "returns a success if it was successful" do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(true)

      params = { user: { username: "name", password: "12341234" } }
      lm = AuthenticatableMock.new(params)

      expect { lm.authenticate! }.to(change { User.all.size }.by(1))
      expect(lm.fail_message).to eq ""
    end

    it "returns successful if binding failed but it was on the database" do
      create(:user, username: "user", password: "12341234")
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(false)
      params = { user: { username: "user", password: "12341234" } }

      lm = AuthenticatableMock.new(params)
      expect { lm.authenticate! }.to_not raise_error
      expect(lm.fail_message).to eq ""
    end
  end

  describe "#guess_email" do
    let(:empty_dc) do
      [
        {
          "dn"    => ["ou=users"],
          "email" => "user@example.com"
        }
      ]
    end

    let(:no_dn) do
      [{ "email" => "user@example.com" }]
    end

    let(:multiple_dn) do
      [
        {
          "dn"    => ["ou=users,dc=example,dc=com"],
          "email" => "user@example.com"
        },
        {
          "dn"    => ["ou=accounts,dc=example,dc=com"],
          "email" => "another@example.com"
        }
      ]
    end

    let(:valid_response) do
      [
        {
          "dn"    => ["ou=users,dc=example,dc=com"],
          "email" => "user@example.com"
        }
      ]
    end

    let(:multiple_emails) do
      [
        {
          "dn"    => ["ou=users,dc=example,dc=com"],
          "email" => ["user1@example.com", "user2@example.com"]
        }
      ]
    end

    let(:params) do
      { user: { username: "name", password: "12341234" } }
    end

    before do
      allow_any_instance_of(Net::LDAP).to receive(:bind_as).and_return(true)

      APP_CONFIG["ldap"]["enabled"]     = true
      APP_CONFIG["ldap"]["guess_email"] = { "enabled" => true, "attr" => "" }
    end

    it "returns a nil email if no records have been found" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      assert_guess_email(params, nil)
    end

    it "returns nil if search fails" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(nil)
      assert_guess_email(params, nil)
    end

    it "returns a nil email if the dn attribute is not there" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(no_dn)
      assert_guess_email(params, nil)
    end

    it "returns a nil email if more than one dn gets returned" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(multiple_dn)
      assert_guess_email(params, nil)
    end

    it "returns a nil email if the dc hostname could not be guessed" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(empty_dc)
      assert_guess_email(params, nil)
    end

    it "returns a valid email if the dc can be guessed" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(valid_response)
      assert_guess_email(params, "name@example.com")
    end

    it "returns a nil email if the specified attribute does not exist" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(valid_response)
      assert_guess_email(params, nil, "non_existing")
    end

    it "returns a valid email if the given attribute exists" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(valid_response)
      assert_guess_email(params, "user@example.com", "email")
    end

    it "returns a the first vaild email if the given attr has a list" do
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(multiple_emails)
      assert_guess_email(params, "user1@example.com", "email")
    end

    it "returns a nil email if search raises an error" do
      allow_any_instance_of(Net::LDAP).to receive(:search) do
        raise ::Net::LDAP::Error, "I AM ERROR"
      end
      assert_guess_email(params, nil)
    end
  end
end
