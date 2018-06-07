# frozen_string_literal: true

require "spec_helper"

describe TeamPolicy do
  subject { described_class }

  let(:admin) { create(:admin) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners:       [owner],
           contributors: [contributor],
           viewers:      [viewer])
  end

  before do
    create(:registry)
  end

  permissions :member? do
    it "denies access to a user who is not part of the team" do
      expect(subject).not_to permit(create(:user), team)
    end

    it "allows access to a member of the team" do
      expect(subject).to permit(viewer, team)
    end

    it "allows access to an admin even if he is not part of the team" do
      expect(subject).to permit(admin, team)
    end
  end

  permissions :update? do
    it "allows access to a user who user is an owner of the team" do
      expect(subject).to permit(owner, team)
    end

    it "disallows access to a user who user is a contributor of the team" do
      expect(subject).not_to permit(contributor, team)
    end

    it "disallows access to a user who user is a viewer of the team" do
      expect(subject).not_to permit(viewer, team)
    end

    it "allows access to an admin even if he is not part of the team" do
      expect(subject).to permit(admin, team)
    end
  end

  describe "scope" do
    it "returns all the non special teams if admin" do
      # Another team not related with 'owner'
      admin_team = create(:team, owners: [create(:admin)])

      expected_list = [team, admin_team]
      expect(Pundit.policy_scope(admin, Team).to_a).to match_array(expected_list)
    end

    it "returns only teams having the user as a member" do
      # Another team not related with 'owner'
      create(:team, owners: [create(:user)])

      expected_list = [team]
      expect(Pundit.policy_scope(viewer, Team).to_a).to match_array(expected_list)
    end

    it "never shows the team associated with personal repository" do
      user = create(:user)
      expect(user.teams).not_to be_empty
      expect(Pundit.policy_scope(user, Team).to_a).to be_empty
    end
  end
end
