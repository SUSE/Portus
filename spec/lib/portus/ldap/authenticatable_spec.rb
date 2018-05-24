# frozen_string_literal: true

require "ostruct"
require "rails_helper"

class LdapMockAdapter
  attr_accessor :opts

  def initialize(opts)
    @opts = opts
  end

  def bind_as(_)
    true
  end
end

class LdapFailedBindAdapter < LdapMockAdapter
  def bind_as(_)
    raise Net::LDAP::Error, "Net::LDAP::Error exception" if ENV["LDAP_RAISE_EXCEPTION"] == "true"
    false
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_operation_result
    code = ENV["LDAP_OPERATION_CODE"] || 1

    OpenStruct.new(
      message: "a message",
      code:    code.to_i
    )
  end
  # rubocop:enable Naming/AccessorMethodName
end

class LdapSearchAdapter
  def initialize(opts)
    @opts = opts
  end

  def search(_)
    @opts
  end
end

class LdapOriginal < Portus::LDAP::Authenticatable
  def adapter
    super
  end
end

class LdapMock < Portus::LDAP::Authenticatable
  attr_reader :params, :user, :fail_message
  attr_accessor :bind_result, :session

  def initialize(params)
    @params = { user: params }
    @bind_result = true
    @fail_message = ""
    @session = {}
    @cfg = ::Portus::LDAP::Configuration.new(@params)
  end

  def load_configuration_test
    initialized_adapter
  end

  def bind_options_test
    bind_options(@cfg)
  end

  def find_or_create_user_test!
    find_or_create_user!(@cfg)
  end

  def success!(user)
    @user = user
  end

  def fail!(msg)
    @fail_message = msg
  end

  def setup_search_mock!(response)
    @ldap = LdapSearchAdapter.new(response)
  end

  def guess_email_test(response)
    @ldap = LdapSearchAdapter.new(response)
    guess_email(@cfg)
  end

  protected

  def adapter
    @bind_result ? LdapMockAdapter : LdapFailedBindAdapter
  end
end

class PortusMock < Portus::LDAP::Authenticatable
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def load_configuration_test
    load_configuration
  end
end

# AuthenticatableMock is a thin layer on top of ::Portus::LDAP::Authenticatable,
# that allows you to define the request parameters. It also allows you to access
# the `session` object. Therefore, this class is designed to mock as least as
# possible.
class AuthenticatableMock < ::Portus::LDAP::Authenticatable
  attr_accessor :params
  attr_accessor :session

  # Sets the request parameters and initializes the session.
  def initialize(params)
    @session = {}
    @params = params
    super
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

describe ::Portus::LDAP::Authenticatable, focus: true do
  before do
    APP_CONFIG["ldap"]["enabled"] = true
    allow_any_instance_of(described_class).to receive(:authenticate!).and_call_original
  end

  context "#adapter" do
    # Let's make code coverage happy
    it "calls the right adapter" do
      ldap = LdapOriginal.new(nil)
      expect(ldap.adapter.to_s).to eq "Net::LDAP"
    end
  end

  it "loads the configuration properly" do
    lm = LdapMock.new(username: "name", password: "1234")
    cfg = lm.load_configuration_test

    expect(cfg).not_to be nil
    expect(cfg.opts[:host]).to eq "hostname"
    expect(cfg.opts[:port]).to eq 389
    expect(cfg.opts[:encryption]).to be nil
    expect(cfg.opts).not_to have_key(:auth)

    # Test different encryption methods.
    [["starttls", :start_tls], ["simple_tls", :simple_tls]].each do |e|
      APP_CONFIG["ldap"]["encryption"]["method"] = e[0]
      cfg = lm.load_configuration_test
      expect(cfg.opts[:encryption][:method]).to eq e[1]
    end

    APP_CONFIG["ldap"]["encryption"]["method"] = "lala"
    cfg = lm.load_configuration_test
    expect(cfg.opts[:encryption]).to be_nil
  end

  context "encryption" do
    it "returns nil on plain" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method" => "plain"
      }

      lm = LdapMock.new(username: "name", password: "1234")
      cfg = lm.load_configuration_test

      expect(cfg.opts[:encryption]).to be_nil
    end

    it "returns some default parameters when options are not given" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method" => "start_tls"
      }

      lm = LdapMock.new(username: "name", password: "1234")
      cfg = lm.load_configuration_test
      expect(cfg.opts[:encryption][:method]).to eq :start_tls
      expect(cfg.opts[:encryption][:tls_options]).to eq OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
    end

    it "adds the CA file" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method"  => "start_tls",
        "options" => { "ca_file" => "/my/pem/file" }
      }

      lm = LdapMock.new(username: "name", password: "1234")
      cfg = lm.load_configuration_test
      expect(cfg.opts[:encryption][:method]).to eq :start_tls
      expect(cfg.opts[:encryption][:tls_options][:ca_file]).to eq "/my/pem/file"
      expect(cfg.opts[:encryption][:tls_options][:ssl_version]).to be_nil
    end

    it "adds the CA file and the SSL version" do
      APP_CONFIG["ldap"]["encryption"] = {
        "method"  => "start_tls",
        "options" => { "ca_file" => "/my/pem/file", "ssl_version" => "TLSv1_1" }
      }

      lm = LdapMock.new(username: "name", password: "1234")
      cfg = lm.load_configuration_test
      expect(cfg.opts[:encryption][:method]).to eq :start_tls
      expect(cfg.opts[:encryption][:tls_options][:ca_file]).to eq "/my/pem/file"
      expect(cfg.opts[:encryption][:tls_options][:ssl_version]).to eq "TLSv1_1"
    end
  end

  it "loads the auth configuration properly" do
    # auth configuration disabled
    auth = { "enabled" => false }
    APP_CONFIG["ldap"]["authentication"] = auth

    lm = LdapMock.new(username: "name", password: "1234")
    cfg = lm.load_configuration_test
    expect(cfg.opts).not_to have_key(:auth)

    # auth configuration enabled
    auth = { "enabled" => true, "bind_dn" => "foo", "password" => "pass" }
    APP_CONFIG["ldap"]["authentication"] = auth

    lm = LdapMock.new(username: "name", password: "1234")
    cfg = lm.load_configuration_test
    expect(cfg.opts[:auth][:username]).to eq "foo"
    expect(cfg.opts[:auth][:password]).to eq "pass"
    expect(cfg.opts[:auth][:method]).to eq :simple
  end

  it "fetches the right bind options" do
    original = APP_CONFIG["ldap"].dup

    APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "uid" => "uid" }
    lm = LdapMock.new(username: "name", password: "1234")
    opts = lm.bind_options_test
    expect(opts.size).to eq 2
    expect(opts[:filter].to_s).to eq "(uid=name)"
    expect(opts[:password]).to eq "1234"

    APP_CONFIG["ldap"] = original
    opts = lm.bind_options_test
    expect(opts.size).to eq 3
    expect(opts[:filter].to_s).to eq "(uid=name)"
    expect(opts[:password]).to eq "1234"
    expect(opts[:base]).to eq "ou=users,dc=example,dc=com"

    APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "uid" => "foo" }
    lm = LdapMock.new(username: "name", password: "12341234")
    opts = lm.bind_options_test
    expect(opts[:filter].to_s).to eq "(foo=name)"

    APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "uid" => "foo", "filter" => "mail=g*" }
    lm = LdapMock.new(username: "name", password: "12341234")
    opts = lm.bind_options_test
    expect(opts[:filter].to_s).to eq "(&(foo=name)(mail=g*))"
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
      APP_CONFIG["ldap"] = { "enabled" => true }
    end

    it "the ldap user could be located" do
      user = create(:user, username: "name")
      lm = LdapMock.new(username: "name", password: "1234")
      ret, created = lm.find_or_create_user_test!
      expect(ret.id).to eq user.id
      expect(created).to be_falsey
    end

    it "creates a new ldap user" do
      lm = LdapMock.new(username: "name", password: "12341234")
      _, created = lm.find_or_create_user_test!

      expect(User.count).to eq 1
      expect(User.find_by(username: "name")).not_to be nil
      expect(created).to be_truthy
    end

    it "creates a new ldap user even if it has weird characters" do
      # Remember that this will create a new admin, so it has its consequences
      # on the expected values in this test.
      create(:registry)

      lm = LdapMock.new(username: "name!o", password: "12341234")
      _, created = lm.find_or_create_user_test!

      expect(User.count).to eq 2
      user = User.find_by(username: "name!o")
      expect(user.username).to eq "name!o"
      expect(user.namespace.name).to eq "name_o"
      expect(created).to be_truthy
    end

    it "allows multiple users to have no email setup" do
      APP_CONFIG["ldap"]["guess_email"] = { "enabled" => false }

      lm = LdapMock.new(username: "name", password: "12341234")
      lm.find_or_create_user_test!

      lm = LdapMock.new(username: "another", password: "12341234")
      lm.find_or_create_user_test!

      expect(User.count).to eq 2
    end

    it "raises the proper error on email duplication" do
      ge = { "enabled" => true, "attr" => "email" }
      APP_CONFIG["ldap"] = { "enabled" => true, "base" => "", "guess_email" => ge }

      lm = LdapMock.new(username: "name", password: "12341234")
      lm.setup_search_mock!(valid_response)
      lm.find_or_create_user_test!

      lm = LdapMock.new(username: "another", password: "12341234")
      lm.setup_search_mock!(valid_response)
      lm.find_or_create_user_test!

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

    it "raises an exception if ldap is not supported" do
      APP_CONFIG["ldap"]["enabled"] = false
      lm = LdapMock.new(username: "name", password: "1234")
      lm.authenticate!
      expect(lm.fail_message).to be "LDAP is disabled"
    end

    it "fails if the user couldn't bind" do
      lm = LdapMock.new(username: "name", password: "12341234")
      lm.bind_result = false
      lm.authenticate!
      expect(lm.fail_message).to eq "a message (code 1)"
    end

    it "fails if the user was not found" do
      ENV["LDAP_OPERATION_CODE"] = "0"

      lm = LdapMock.new(username: "name", password: "12341234")
      lm.bind_result = false
      lm.authenticate!
      expect(lm.fail_message).to eq "Could not find user 'name'"
    end

    it "can rescue Net::LDAP::Error exceptions" do
      ENV["LDAP_RAISE_EXCEPTION"] = "true"

      lm = LdapMock.new(username: "name", password: "12341234")
      lm.bind_result = false
      lm.authenticate!
      expect(lm.fail_message).to eq "Net::LDAP::Error exception"
    end

    it "fails when creating a user went wrong" do
      allow_any_instance_of(User).to receive(:valid?).and_return(false)
      allow_any_instance_of(User).to(
        receive(:errors)
          .and_return(OpenStruct.new(full_messages: ["error message"]))
      )

      lm = LdapMock.new(username: "cw-name", password: "1234")
      lm.authenticate!
      expect(lm.fail_message).to eq "error message"
    end

    it "returns a success if it was successful" do
      lm = LdapMock.new(username: "name", password: "12341234")
      lm.authenticate!
      expect(lm.fail_message).to be ""
      expect(lm.user.username).to eq "name"
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
  end
end
