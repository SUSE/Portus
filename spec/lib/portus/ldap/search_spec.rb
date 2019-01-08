# frozen_string_literal: true

describe ::Portus::LDAP::Search do
  let(:success) { OpenStruct.new(code: 0) }
  let(:failure) { OpenStruct.new(code: 1) }

  describe "#with_error_message" do
    it "returns nil if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(subject.with_error_message("name")).to be_nil
    end

    it "returns nil if the name doesn't exist" do
      allow_any_instance_of(described_class).to receive(:search_admin_or_user).and_return([])
      APP_CONFIG["ldap"]["enabled"] = true

      expect(subject.with_error_message("name")).to be_nil
    end

    it "returns the message if the user exist" do
      allow_any_instance_of(described_class).to receive(:search_admin_or_user).and_return([1])
      APP_CONFIG["ldap"]["enabled"] = true

      expect(subject.with_error_message("name")).not_to be_nil
    end
  end

  describe "#find_user" do
    it "returns an empty array if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(subject.find_user("name")).to be_empty
    end

    it "returns an empty array if calling #search returned an empty value" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.find_user("name")).to be_empty
    end

    it "returns an empty array if calling #search raised an LDAP::Error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search) do
        raise ::Net::LDAP::Error.new, "error"
      end

      expect(subject.find_user("name")).to be_empty
    end
  end

  describe "#exists?" do
    it "returns false if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(subject.exists?("name")).to be_falsey
    end

    it "returns false if calling #search returned an empty value" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.exists?("name")).to be_falsey
    end

    it "returns false if calling #search raised an LDAP::Error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search) do
        raise ::Net::LDAP::Error.new, "error"
      end

      expect(subject.exists?("name")).to be_falsey
    end

    it "returns true if everything went as expected" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to(receive(:search).and_return(["somepropercn"]))
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.exists?("name")).to be_truthy
    end
  end

  describe "#find_group_and_members" do
    it "returns an empty array if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false

      expect(subject.find_group_and_members("name")).to be_empty
    end

    it "returns an empty array if calling #search returned an empty value" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.find_group_and_members("name")).to be_empty
    end

    it "returns an empty array if calling #search had a non-zero error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(failure)

      expect(subject.find_group_and_members("name")).to be_empty
    end

    it "returns an empty array if calling #search raised an LDAP::Error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to receive(:search) do
        raise ::Net::LDAP::Error.new, "error"
      end

      expect(subject.find_group_and_members("name")).to be_empty
    end

    it "returns the results as expected" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(Net::LDAP).to(
        receive(:search).and_return(
          [{ uniquemember: ["uid=another,dc=example,dc=org", "uid=user,dc=example,dc=org"] }]
        )
      )
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      results = subject.find_group_and_members("name")
      expect(results.sort).to eq %w[another user]
    end
  end

  describe "#user_groups" do
    let(:user_entries) { [OpenStruct.new(dn: "uid=user,dn=example,dn=org")] }
    let(:group_entries) { [OpenStruct.new(dn: "cn=team1,ou=groups,dn=example,dn=org")] }

    before do
      APP_CONFIG["ldap"]["enabled"] = true
    end

    it "returns an empty array if the user could not be found" do
      allow_any_instance_of(::Portus::LDAP::Search).to receive(:find_user).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.user_groups("whatever")).to be_empty
    end

    it "returns an empty array if no groups were found" do
      allow_any_instance_of(::Portus::LDAP::Search).to receive(:find_user).and_return(user_entries)
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.user_groups("user")).to be_empty
    end

    it "returns an empty array if calling #search raised an LDAP::Error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(::Portus::LDAP::Search).to receive(:find_user) do
        raise ::Net::LDAP::Error.new, "error"
      end

      expect(subject.user_groups("user")).to be_empty
    end

    it "returns an empty array if calling #search on #groups_from returned an error" do
      APP_CONFIG["ldap"]["enabled"] = true
      allow_any_instance_of(::Portus::LDAP::Search).to receive(:find_user).and_return(user_entries)
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return([])
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(failure)

      expect(subject.user_groups("user")).to be_empty
    end

    it "returns a list of groups" do
      allow_any_instance_of(::Portus::LDAP::Search).to receive(:find_user).and_return(user_entries)
      allow_any_instance_of(Net::LDAP).to receive(:search).and_return(group_entries)
      allow_any_instance_of(Net::LDAP).to receive(:get_operation_result).and_return(success)

      expect(subject.user_groups("user")).to eq ["team1"]
    end
  end
end
