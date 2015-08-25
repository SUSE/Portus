require "rails_helper"

describe RepositoryPolicy do

  subject { described_class }

  let(:registry)    { create(:registry) }
  let(:user)        { create(:user) }
  let(:user2)       { create(:user) }
  let(:team)        { create(:team, owners: [user]) }
  let(:team2)       { create(:team, owners: [user2]) }

  describe "scope" do
    before :each do
      public_namespace = create(:namespace, team: team2, public: true, registry: registry)
      @public_repository = create(:repository, namespace: public_namespace)

      private_namespace = create(:namespace, team: team2, registry: registry)
      @private_repository = create(:repository, namespace: private_namespace)

      namespace = create(:namespace, team: team, registry: registry)
      @repository = create(:repository, namespace: namespace)
    end

    it "include repositories that are part of public namespaces" do
      expect(Pundit.policy_scope(user, Repository).to_a).to include(@public_repository)
    end

    it "include repositories that are part of namespace controlled by a team to which " \
      "the user belongs" do

      expect(Pundit.policy_scope(user, Repository).to_a).to include(@repository)
    end

    it "never shows repositories inside of private namespaces" do
      expect(Pundit.policy_scope(user, Repository).to_a).not_to include(@private_repository)
    end
  end

  describe "search" do
    let!(:namespace)  { create(:namespace, team: team, name: "mssola") }
    let!(:repository) { create(:repository, namespace: namespace, name: "repository") }

    it "finds the same repository regardless to how it has been written"  do
      %w(repository rep epo).each do |name|
        repo = Pundit.policy_scope(user, Repository).search(name)
        expect(repo.name).to eql "Repository"
      end
    end

    it "finds repos with the `repo:tag` syntax" do
      %w(repository rep epo).each do |name|
        name = "#{name}:tag"
        repo = Pundit.policy_scope(user, Repository).search(name)
        expect(repo.name).to eql "Repository"
      end
    end
  end
end
