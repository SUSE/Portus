# frozen_string_literal: true

describe ::Portus::LDAP::Search do
  context "#with_error_message" do
    it "returns nil if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(described_class.new.with_error_message("name")).to be_nil
    end

    it "returns nil if the name doesn't exist" do
      allow_any_instance_of(described_class).to receive(:search_admin_or_user).and_return([])
      APP_CONFIG["ldap"]["enabled"] = true

      expect(described_class.new.with_error_message("name")).to be_nil
    end

    it "returns the message if the user exist" do
      allow_any_instance_of(described_class).to receive(:search_admin_or_user).and_return([1])
      APP_CONFIG["ldap"]["enabled"] = true

      expect(described_class.new.with_error_message("name")).not_to be_nil
    end
  end
end
