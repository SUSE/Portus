# frozen_string_literal: true

require "rails_helper"

describe NamespacePolicy do
  subject { described_class }

  let!(:registry)   { create(:registry) }
  let(:admin)       { create(:admin) }
  let(:user)        { create(:user) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners:       [owner],
           contributors: [contributor],
           viewers:      [viewer])
  end
  let(:namespace) do
    create(
      :namespace,
      description: "short test description.",
      registry:    registry,
      team:        team
    )
  end

  before do
    @admin = create(:admin)
  end

  permissions :pull? do
    it "allows access to user with viewer role" do
      expect(subject).to permit(viewer, namespace)
    end

    it "allows access to user with contributor role" do
      expect(subject).to permit(contributor, namespace)
    end

    it "allows access to user with owner role" do
      expect(subject).to permit(owner, namespace)
    end

    it "disallows access to user who is not part of the team" do
      expect(subject).not_to permit(user, namespace)
    end

    it "allows access to any user if the namespace is public" do
      namespace.visibility = :visibility_public
      expect(subject).to permit(user, namespace)
    end

    it "allows access to admin users even if they are not part of the team" do
      expect(subject).to permit(@admin, namespace)
    end

    it "always allows access to a global namespace" do
      expect(subject).to permit(user, registry.global_namespace)
    end

    it "disallows access to a non-logged user if the namespace is private" do
      expect do
        subject.new(nil, namespace).pull?
      end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
    end

    it "allows access to a non-logged user if the namespace is public" do
      namespace.visibility = :visibility_public
      expect(subject).to permit(nil, namespace)
    end

    it "disallows access to a non-logged-in user if the namespace is protected" do
      namespace.visibility = :visibility_protected
      expect do
        subject.new(nil, namespace).pull?
      end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
    end

    it "allows access to any logged-in user if the namespace is protected" do
      namespace.visibility = :visibility_protected
      expect(subject).to permit(user, namespace)
      expect(subject).to permit(viewer, namespace)
      expect(subject).to permit(owner, namespace)
      expect(subject).to permit(@admin, namespace)
    end
  end

  permissions :push? do
    context "global namespace" do
      it "allows access to administrators" do
        expect(subject).to permit(@admin, registry.global_namespace)
      end

      it "denies access to other users" do
        expect(subject).not_to permit(user, registry.global_namespace)
      end
    end

    context "user_permission.push_images.policy is set to admin-only" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "admin-only"
        contributor.create_personal_namespace!
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "owner cannot push to team namespace" do
        expect(subject).to_not permit(owner, namespace)
      end

      it "contributor cannot push to team namespace" do
        expect(subject).to_not permit(contributor, namespace)
      end

      it "viewer cannot push to team namespace" do
        expect(subject).to_not permit(viewer, namespace)
      end

      it "does not allow access to the personal namespace" do
        expect(subject).to_not permit(contributor, contributor.namespace)
      end

      it "disallows access to user who is not part of the team" do
        expect(subject).not_to permit(user, namespace)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, namespace).push?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end

    context "user_permission.push_images.policy is set to allow-personal" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
        contributor.create_personal_namespace!
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "owner cannot push to team namespace" do
        expect(subject).to_not permit(owner, namespace)
      end

      it "contributor cannot push to team namespace" do
        expect(subject).to_not permit(contributor, namespace)
      end

      it "viewer cannot push to team namespace" do
        expect(subject).to_not permit(viewer, namespace)
      end

      it "allows access to the personal namespace" do
        expect(subject).to permit(contributor, contributor.namespace)
      end

      it "disallows access to user who is not part of the team" do
        expect(subject).not_to permit(user, namespace)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, namespace).push?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end

    context "user_permission.push_images.policy is set to allow-teams" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-teams"
        contributor.create_personal_namespace!
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "owner can push to team namespace" do
        expect(subject).to permit(owner, namespace)
      end

      it "contributor can push to team namespace" do
        expect(subject).to permit(contributor, namespace)
      end

      it "viewer cannot push to team namespace" do
        expect(subject).to_not permit(viewer, namespace)
      end

      it "allows access to the personal namespace" do
        expect(subject).to permit(contributor, contributor.namespace)
      end

      it "disallows access to user who is not part of the team" do
        expect(subject).not_to permit(user, namespace)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, namespace).push?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end

    context "user_permission.push_images.policy is set to an unknown value" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "unknown"
      end

      it "it logs a warning and does not allow access to admins" do
        expect(Rails.logger).to receive(:warn).with("Unknown push policy 'unknown'")
        expect(subject).to_not permit(@admin, namespace)
      end
    end
  end

  # The push? and all? are aliases, so they should share the same tests.
  delete_all = lambda { |_example|
    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "allows access to administrators" do
      expect(subject).to permit(@admin, namespace)
    end

    it "allows access to owners" do
      expect(subject).to permit(owner, namespace)
    end

    it "allows access to contributors if config enabled it" do
      APP_CONFIG["delete"]["contributors"] = true
      expect(subject).to permit(contributor, namespace)
    end

    it "denies access to contributors if config disabled it" do
      APP_CONFIG["delete"]["contributors"] = false
      expect(subject).not_to permit(contributor, namespace)
    end

    it "denies access to other users" do
      expect(subject).not_to permit(user, namespace)
    end

    it "denies access if delete is disabled" do
      APP_CONFIG["delete"]["enabled"] = false
      expect(subject).not_to permit(@admin, namespace)
    end
  }

  permissions :delete?, &delete_all
  permissions :all?, &delete_all

  permissions :destroy? do
    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "does not allow if delete is disabled" do
      APP_CONFIG["delete"]["enabled"] = false
      expect(subject).not_to permit(@admin, namespace)
    end

    it "allows to delete for admin" do
      expect(subject).to permit(@admin, namespace)
    end

    it "allows an onwer to delete the namespace" do
      expect(subject).to permit(owner, namespace)
    end

    it "disallows a contributor to delete the namespace" do
      expect(subject).not_to permit(contributor, namespace)
    end

    it "allows a contributor to delete the namespace when configured" do
      APP_CONFIG["delete"]["contributors"] = true
      expect(subject).to permit(contributor, namespace)
    end

    it "disallows everyone to destroy a global namespace" do
      global = Namespace.find_by(global: true)
      expect(subject).to_not permit(@admin, global)
    end
  end

  permissions :change_visibility? do
    it "allows admin to change it" do
      expect(subject).to permit(@admin, namespace)
    end

    it "disallows access to user who is not part of the team" do
      expect(subject).not_to permit(user, namespace)
    end

    it "disallow access to user with viewer role" do
      expect(subject).not_to permit(viewer, namespace)
    end

    it "disallow access to user with contributor role" do
      expect(subject).not_to permit(contributor, namespace)
    end

    it "disallows access to user who is not logged in" do
      expect do
        subject.new(nil, namespace).change_visibility?
      end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
    end

    context "global namespace" do
      let(:namespace) { create(:namespace, global: true, visibility: :visibility_public) }

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "disallows access to everyone normal users" do
        expect(subject).not_to permit(user, namespace)
      end
    end
  end

  permissions :update? do
    context "feature enabled" do
      before do
        APP_CONFIG["user_permission"]["manage_namespace"]["enabled"] = true
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "allows access to user with owner role" do
        expect(subject).to permit(owner, namespace)
      end

      it "disallows access to user with contributor role" do
        expect(subject).not_to permit(contributor, namespace)
      end

      it "disallows access to user with viewer role" do
        expect(subject).not_to permit(viewer, namespace)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, namespace).update?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end

    context "feature disabled" do
      before do
        APP_CONFIG["user_permission"]["manage_namespace"]["enabled"] = false
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, namespace)
      end

      it "disallows access to user with owner role" do
        expect(subject).not_to permit(owner, namespace)
      end

      it "disallows access to user with contributor role" do
        expect(subject).not_to permit(contributor, namespace)
      end

      it "disallows access to user with viewer role" do
        expect(subject).not_to permit(viewer, namespace)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, namespace).update?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end
  end

  permissions :create? do
    context "feature enabled" do
      before do
        APP_CONFIG["user_permission"]["create_namespace"]["enabled"] = true
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, nil)
      end

      it "allows access to user with owner role" do
        expect(subject).to permit(owner, team.namespaces.build)
      end

      it "allows access to user with contributor role" do
        expect(subject).to permit(contributor, team.namespaces.build)
      end

      it "disallows access to user with viewer role" do
        expect(subject).not_to permit(viewer, team.namespaces.build)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, nil).update?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end

    context "feature disabled" do
      before do
        APP_CONFIG["user_permission"]["create_namespace"]["enabled"] = false
      end

      it "allows access to admin" do
        expect(subject).to permit(@admin, nil)
      end

      it "disallows access to user with owner role" do
        expect(subject).not_to permit(owner, team.namespaces.build)
      end

      it "disallows access to user with contributor role" do
        expect(subject).not_to permit(contributor, team.namespaces.build)
      end

      it "disallows access to user with viewer role" do
        expect(subject).not_to permit(viewer, team.namespaces.build)
      end

      it "disallows access to user who is not logged in" do
        expect do
          subject.new(nil, nil).create?
        end.to raise_error(Pundit::NotAuthorizedError, /must be logged in/)
      end
    end
  end

  describe "scope" do
    before do
      # force creation of namespace
      namespace
    end

    it "shows namespaces controlled by teams the user is member of" do
      team.namespaces.each do |n|
        expect(Pundit.policy_scope(owner, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(contributor, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(viewer, Namespace).to_a).to include(n)
      end
    end

    it "shows namespaces for admin even if not member" do
      team.namespaces.each do |n|
        expect(Pundit.policy_scope(admin, Namespace).to_a).to include(n)
      end
    end

    it "does't show namespaces for regular user if not member" do
      team.namespaces.each do |n|
        expect(Pundit.policy_scope(user, Namespace).to_a).not_to include(n)
      end
    end

    it "shows global namespaces to everyone" do
      global = Namespace.where(global: true)

      global.each do |n|
        expect(Pundit.policy_scope(admin, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(owner, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(contributor, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(viewer, Namespace).to_a).to include(n)
        expect(Pundit.policy_scope(user, Namespace).to_a).to include(n)
      end
    end

    it "shows public namespaces to everyone" do
      n = create(:namespace, visibility: :visibility_public)
      create(:team, namespaces: [n], owners: [owner])

      expect(Pundit.policy_scope(admin, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(owner, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(contributor, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(viewer, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(user, Namespace).to_a).to include(n)
    end

    it "shows protected namespaces to everyone" do
      n = create(:namespace, visibility: :visibility_protected)
      create(:team, namespaces: [n], owners: [owner])

      expect(Pundit.policy_scope(admin, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(owner, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(contributor, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(viewer, Namespace).to_a).to include(n)
      expect(Pundit.policy_scope(user, Namespace).to_a).to include(n)
    end

    it "shows personal namespaces for specific user" do
      expect(Pundit.policy_scope(user, Namespace).to_a).to include(user.namespace)
    end
  end
end
