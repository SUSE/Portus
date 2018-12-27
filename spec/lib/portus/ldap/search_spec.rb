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

  context "#find_group_and_members" do
    it "returns an empty array if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(described_class.new.find_group_and_members("name")).to be_empty
    end

    it "returns an empty array if calling #search returned an empty value" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])

      expect(described_class.new.find_group_and_members("name")).to be_empty
    end

    it "returns the results as expected" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to(
        receive(:search).and_return(
          [{ uniquemember: ["uid=another,dc=example,dc=org", "uid=user,dc=example,dc=org"] }]
        )
      )

      results = described_class.new.find_group_and_members("name")
      expect(results.sort).to eq ["another", "user"]
    end
  end
end
