# frozen_string_literal: true

require "rails_helper"

describe ::Portus::Mail::Utils do
  let(:no_smtp) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => { "enabled": false }
    }.freeze
  end

  let(:basic) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => {
        "enabled"              => true,
        "address"              => "address@example.com",
        "port"                 => 567,
        "domain"               => "example.com",
        "enable_starttls_auto" => false,
        "openssl_verify_mode"  => "none"
      }
    }.freeze
  end

  let(:authentication) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => {
        "enabled"              => true,
        "address"              => "address@example.com",
        "port"                 => 567,
        "domain"               => "example.com",
        "enable_starttls_auto" => false,
        "openssl_verify_mode"  => "none",
        "user_name"            => "mssola",
        "password"             => "password",
        "authentication"       => "login"
      }
    }.freeze
  end

  let(:tls_noca) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => {
        "enabled"              => true,
        "address"              => "address@example.com",
        "port"                 => 567,
        "domain"               => "example.com",
        "enable_starttls_auto" => true,
        "openssl_verify_mode"  => "peer",
        "ssl_tls"              => "tls"
      }
    }.freeze
  end

  let(:notls_ca) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => {
        "enabled"              => true,
        "address"              => "address@example.com",
        "port"                 => 567,
        "domain"               => "example.com",
        "enable_starttls_auto" => true,
        "openssl_verify_mode"  => "peer",
        "ca_path"              => "/lala",
        "ca_file"              => "/lala"
      }
    }.freeze
  end

  let(:ssl_ca) do
    {
      "from" => "lala@example.com",
      "name" => "test",
      "smtp" => {
        "enabled"              => true,
        "address"              => "address@example.com",
        "port"                 => 567,
        "domain"               => "example.com",
        "enable_starttls_auto" => true,
        "openssl_verify_mode"  => "peer",
        "ca_path"              => "/lala",
        "ca_file"              => "/lala",
        "ssl_tls"              => "ssl"
      }
    }.freeze
  end

  describe "#check_email_configuration!" do
    it "raises an exception on malformed 'from'" do
      expect do
        described_class.new("from" => "!").check_email_configuration!
      end.to raise_error(::Portus::Mail::ConfigurationError)
    end

    it "raises an exception on malformed 'reply_to'" do
      expect do
        described_class.new("from" => "lal@ex.org", "reply_to" => "!").check_email_configuration!
      end.to raise_error(::Portus::Mail::ConfigurationError)
    end

    it "does not raise an exception when everything is alright" do
      expect do
        hsh = { "from" => "lal@ex.org", "reply_to" => "lal@ex.org" }
        described_class.new(hsh).check_email_configuration!
      end.not_to raise_error
    end
  end

  describe "#smtp_settings" do
    it "returns nil when disabled" do
      res = described_class.new(no_smtp).smtp_settings
      expect(res).to be_nil
    end

    it "returns a basic smtp configuration" do
      res = described_class.new(basic).smtp_settings
      %i[address port domain enable_starttls_auto openssl_verify_mode].each do |key|
        expect(res[key]).not_to be_nil
      end
    end

    it "returns a configuration with authentication" do
      res = described_class.new(authentication).smtp_settings
      %i[address port domain enable_starttls_auto openssl_verify_mode
         user_name password authentication].each do |key|
        expect(res[key]).not_to be_nil
      end
    end

    it "returns a configuration with SSL (ssl/tls and no ca)" do
      res = described_class.new(tls_noca).smtp_settings
      %i[address port domain enable_starttls_auto openssl_verify_mode tls].each do |key|
        expect(res[key]).not_to be_nil
      end
    end

    it "returns a configuration with SSL (ssl/tls and ca)" do
      res = described_class.new(ssl_ca).smtp_settings
      %i[address port domain enable_starttls_auto openssl_verify_mode ssl
         ca_file ca_path].each do |key|
        expect(res[key]).not_to be_nil
      end
    end

    it "returns a configuration with SSL (no ssl/tls and ca)" do
      res = described_class.new(notls_ca).smtp_settings
      %i[address port domain enable_starttls_auto openssl_verify_mode
         ca_file ca_path].each do |key|
        expect(res[key]).not_to be_nil
      end
    end
  end
end
