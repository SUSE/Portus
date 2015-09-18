require "rails_helper"

describe ErrorsController do
  describe "GET #show" do

    before :all do
      secrets = Rails.application.secrets
      @secret_key_base = secrets.secret_key_base
      @secret_machine_fqdn = secrets.machine_fqdn
      @secret_encryption_private_key_path = secrets.encryption_private_key_path
      @secret_portus_password = secrets.portus_password
    end

    before :each do
      secrets = Rails.application.secrets
      secrets.secret_key_base = @secret_key_base
      secrets.machine_fqdn = @secret_machine_fqdn
      secrets.encryption_private_key_path = @secret_encryption_private_key_path
      secrets.portus_password = @secret_portus_password
    end

    after :all do
      secrets = Rails.application.secrets
      secrets.secret_key_base = @secret_key_base
      secrets.machine_fqdn = @secret_machine_fqdn
      secrets.encryption_private_key_path = @secret_encryption_private_key_path
      secrets.portus_password = @secret_portus_password
    end

    it "sets @fix[:secret_key_base] as true" do
      Rails.application.secrets.secret_key_base = "CHANGE_ME"
      get :show, id: 1
      expect(assigns(:fix)[:secret_key_base]).to be true
    end

    it "sets @fix[:secret_machine_fqdn] as true" do
      Rails.application.secrets.machine_fqdn = nil
      get :show, id: 1
      expect(assigns(:fix)[:secret_machine_fqdn]).to be true
    end

    it "sets @fix[:secret_encryption_private_key_path] as true" do
      Rails.application.secrets.encryption_private_key_path = nil
      get :show, id: 1
      expect(assigns(:fix)[:secret_encryption_private_key_path]).to be true
    end

    it "sets @fix[:secret_portus_password] as true" do
      Rails.application.secrets.portus_password = nil
      get :show, id: 1
      expect(assigns(:fix)[:secret_portus_password]).to be true
    end

  end

  describe "GET #show in production mode" do
    after :all do
      Rails.env = ActiveSupport::StringInquirer.new("test")
    end

    context "production environment" do
      before :each do
        Rails.env = ActiveSupport::StringInquirer.new("production")
      end

      it "sets @fix[:ssl] as true when check_ssl_usage is enabled" do
        APP_CONFIG["check_ssl_usage"] = { "enabled" => true }
        get :show, id: 1
        expect(assigns(:fix)[:ssl]).to be true
      end

      it "sets @fix[:ssl] as false when check_ssl_usage is disabled" do
        APP_CONFIG["check_ssl_usage"] = { "enabled" => false }
        get :show, id: 1
        expect(assigns(:fix)[:ssl]).to be false
      end
    end

  end
end
