# frozen_string_literal: true

require "rails_helper"

describe RepositoryPolicy do
  subject { described_class }

  let(:registry)    { create(:registry) }
  let(:user)        { create(:user) }
  let(:user2)       { create(:user) }
  let(:team)        { create(:team, owners: [user]) }
  let(:team2)       { create(:team, owners: [user2]) }

  permissions :show? do
    before do
      public_namespace = create(
        :namespace,
        team:       team2,
        visibility: Namespace.visibilities[:visibility_public],
        registry:   registry
      )
      @public_repository = create(:repository, namespace: public_namespace)

      protected_namespace = create(
        :namespace,
        team:       team2,
        visibility: Namespace.visibilities[:visibility_protected],
        registry:   registry
      )
      @protected_repository = create(:repository, namespace: protected_namespace)

      private_namespace = create(:namespace, team: team2, registry: registry)
      @private_repository = create(:repository, namespace: private_namespace)
    end

    it "grants access if the user is an admin" do
      admin = create(:admin)
      testing_repositories = [@public_repository, @private_repository]
      testing_repositories.each do |repository|
        expect(subject).to permit(admin, repository)
      end
    end

    it "grants access if the namespace is public" do
      expect(subject).to permit(user, @public_repository)
    end

    it "grants access if the namespace is protected" do
      expect(subject).to permit(user, @protected_repository)
    end

    it "grants access if the repository belongs to a namespace of a team member" do
      user3 = create(:user)
      TeamUser.create(team: team2, user: user3, role: TeamUser.roles["viewer"])
      expect(subject).to permit(user3, @private_repository)
    end

    it "denies access if repository is private and the user is no team member or an admin" do
      expect(subject).not_to permit(user, @private_repository)
    end

    context "Anonymous users" do
      it "grants access if the namespace is public and the user is anonymous" do
        expect(subject).to permit(nil, @public_repository)
      end

      it "does not grant access if the namespace is private and the user is anonymous" do
        expect(subject).not_to permit(nil, @private_repository)
      end
    end
  end

  permissions :destroy? do
    before do
      namespace = create(:namespace, team: team2, registry: registry)
      global_team = registry.global_namespace.team
      global_namespace = create(:namespace, team: global_team, registry: registry)
      @repository = create(:repository, namespace: namespace)
      @global_repository = create(:repository, namespace: global_namespace)
    end

    context "delete disabled" do
      before do
        APP_CONFIG["delete"] = { "enabled" => false }
      end

      it "denies access to admin" do
        admin = create(:admin)
        expect(subject).not_to permit(admin, @repository)
        expect(subject).not_to permit(admin, @global_repository)
      end

      it "denies access to owner" do
        owner = create(:user)
        TeamUser.create(team: team2, user: owner, role: TeamUser.roles["owner"])

        expect(subject).not_to permit(owner, @repository)
        expect(subject).not_to permit(owner, @global_repository)
      end

      it "denies access to contributor" do
        contributor = create(:user)
        TeamUser.create(team: team2, user: contributor, role: TeamUser.roles["contributor"])

        expect(subject).not_to permit(contributor, @repository)
        expect(subject).not_to permit(contributor, @global_repository)
      end

      it "denies access to non-member" do
        expect(subject).not_to permit(user, @repository)
        expect(subject).not_to permit(user, @global_repository)
      end
    end

    context "delete enabled" do
      before do
        APP_CONFIG["delete"] = { "enabled" => true }
      end

      it "grants access to admin" do
        admin = create(:admin)
        expect(subject).to permit(admin, @repository)
        expect(subject).to permit(admin, @global_repository)
      end

      it "grants access to owner" do
        owner = create(:user)
        global_team = @global_repository.namespace.team
        TeamUser.create(team: team2, user: owner, role: TeamUser.roles["owner"])
        TeamUser.create(team: global_team, user: owner, role: TeamUser.roles["owner"])

        expect(subject).to permit(owner, @repository)
        expect(subject).to permit(owner, @global_repository)
      end

      it "denies access to contributor" do
        contributor = create(:user)
        global_team = @global_repository.namespace.team
        TeamUser.create(team: team2, user: contributor, role: TeamUser.roles["contributor"])
        TeamUser.create(team: global_team, user: contributor, role: TeamUser.roles["contributor"])

        expect(subject).not_to permit(contributor, @repository)
        expect(subject).not_to permit(contributor, @global_repository)
      end

      it "denies access to non-member" do
        expect(subject).not_to permit(user, @repository)
        expect(subject).not_to permit(user, @global_repository)
      end
    end

    context "delete contributors enabled" do
      before do
        APP_CONFIG["delete"] = {
          "enabled"      => true,
          "contributors" => true
        }
      end

      it "grants access to contributor" do
        contributor = create(:user)
        global_team = @global_repository.namespace.team
        TeamUser.create(team: team2, user: contributor, role: TeamUser.roles["contributor"])
        TeamUser.create(team: global_team, user: contributor, role: TeamUser.roles["contributor"])

        expect(subject).to permit(contributor, @repository)
        expect(subject).to permit(contributor, @global_repository)
      end
    end
  end

  describe "scope" do
    before do
      public_namespace = create(
        :namespace,
        team:       team2,
        visibility: Namespace.visibilities[:visibility_public],
        registry:   registry
      )
      @public_repository = create(:repository, namespace: public_namespace)

      protected_namespace = create(
        :namespace,
        team:       team2,
        visibility: Namespace.visibilities[:visibility_protected],
        registry:   registry
      )
      @protected_repository = create(:repository, namespace: protected_namespace)

      private_namespace = create(:namespace, team: team2, registry: registry)
      @private_repository = create(:repository, namespace: private_namespace)

      namespace = create(:namespace, team: team, registry: registry)
      @repository = create(:repository, namespace: namespace)
    end

    it "includes the repositories of public/protected namespaces to admin" do
      admin = create(:admin)
      expect(Pundit.policy_scope(admin, Repository).to_a).to include(@public_repository)
      expect(Pundit.policy_scope(admin, Repository).to_a).to include(@protected_repository)
    end

    it "includes repositories of public namespaces to anonnymous" do
      expect(Pundit.policy_scope(nil, Repository).to_a).to include(@public_repository)
    end

    it "includes repositories of public namespaces to user" do
      expect(Pundit.policy_scope(user, Repository).to_a).to include(@public_repository)
    end

    it "includes repositories of namespace controlled by a team to which " \
      "the user belongs" do

      expect(Pundit.policy_scope(user, Repository).to_a).to include(@repository)
    end

    it "never shows repositories of private namespaces" do
      expect(Pundit.policy_scope(user, Repository).to_a).not_to include(@private_repository)
    end
  end

  describe "search" do
    let!(:namespace)  { create(:namespace, team: team, name: "mssola") }
    let!(:repository) { create(:repository, namespace: namespace, name: "repository") }

    it "finds the same repository regardless to how it has been written" do
      %w[repository rep epo].each do |name|
        repo = Pundit.policy_scope(user, Repository).search(name)
        expect(repo.name).to eql "Repository"
      end
    end

    it "finds repos with the `repo:tag` syntax" do
      %w[repository rep epo].each do |name|
        name = "#{name}:tag"
        repo = Pundit.policy_scope(user, Repository).search(name)
        expect(repo.name).to eql "Repository"
      end
    end
  end
end
