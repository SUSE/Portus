# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  hidden             :boolean          default(FALSE)
#  description        :text(65535)
#  ldap_group_checked :integer          default(0)
#  checked_at         :datetime
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#

require "rails_helper"

describe Team do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owners) }
  it { is_expected.to have_many(:namespaces) }

  it "does not check whether the given name is downcased or not" do
    # Does not check name case because:
    # - default namespace is not provided anymore on team creation
    # [ISSUE #234](https://github.com/SUSE/Portus/issues/234)
    # [PR #235](https://github.com/SUSE/Portus/pull/235)
    expect { FactoryBot.create(:team, name: "TeAm") }.not_to raise_error
  end

  it "Counts all the non special teams" do
    # The registry does not count.
    # NOTE: the registry factory also creates a user.
    create(:registry)
    expect(described_class.all_non_special).to be_empty
    expect(described_class.count).to be(2)

    # Creating a proper team, this counts.
    create(:team, owners: [User.first])
    expect(described_class.all_non_special.count).to be(1)
    expect(described_class.count).to be(3)

    # Personal namespaces don't count.
    create(:user)
    expect(described_class.all_non_special.count).to be(1)
    expect(described_class.count).to be(4)
  end

  describe "make_valid" do
    it "does nothing if there's no team with the name" do
      name = "something"

      expect(described_class.make_valid(name)).to eq name
    end

    it "adds an increment if a team with the name already exists" do
      name = "something"

      create(:team, name: name)
      expect(described_class.make_valid(name)).to eq "#{name}0"

      create(:team, name: "#{name}0")
      expect(described_class.make_valid(name)).to eq "#{name}1"
    end
  end

  describe "#ldap_add_members!" do
    it "marks the team as checked" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:find_group_and_members).and_return(["user"])
      )
      t = create(:team, owners: [create(:user, username: "user")])

      expect(t.checked_at).to be_nil
      expect { t.ldap_add_members! }.to(
        change { t.ldap_group_checked }
          .from(Team.ldap_statuses[:unchecked])
          .to(Team.ldap_statuses[:checked])
      )
      expect(t.checked_at).not_to be_nil
    end

    it "skips users that already exist" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:find_group_and_members).and_return(["user"])
      )
      t = create(:team, owners: [create(:user, username: "user")])

      t.ldap_add_members!
      expect(t).not_to receive(:add_team_member!)
    end

    it "skips users which are not available on the DB" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:find_group_and_members).and_return(["another"])
      )
      t = create(:team, owners: [create(:user, username: "user")])

      t.ldap_add_members!
      expect(t).not_to receive(:add_team_member!)
    end

    it "adds a regular user with the default given role" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:find_group_and_members).and_return(["user"])
      )
      create(:user, username: "user")
      t = create(:team, owners: [create(:user, username: "admin")])

      t.ldap_add_members!
      expect(t.viewers.map(&:username)).to eq ["user"]
    end

    it "adds an admin user as owner" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:find_group_and_members).and_return(["user"])
      )
      create(:admin, username: "user")
      t = create(:team, owners: [create(:user, username: "admin")])

      t.ldap_add_members!
      t = t.reload
      expect(t.owners.map(&:username).sort).to eq %w[admin user]
    end
  end

  describe "#add_team_member!" do
    it "does not add a user if there's something wrong about it" do
      t = create(:team, owners: [create(:user, username: "admin")])

      expect(Rails.logger).to(
        receive(:warn).with("Could not add team member: User has already been taken")
      )

      t.add_team_member!(User.portus, "admin")
      t = t.reload
      expect(t.owners.map(&:username).sort).to eq ["admin"]
    end
  end
end
