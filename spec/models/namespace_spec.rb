require "rails_helper"

describe Namespace do

  it { should have_many(:repositories) }
  it { should belong_to(:team) }
  it { should validate_presence_of(:name) }
  it { should allow_value("test1", "1test", "another-test").for(:name) }
  it { should_not allow_value("TesT1", "1Test", "another_test!").for(:name) }

  context "sanitize name" do
    it "replaces white spaces with underscores" do
      expect(Namespace.sanitize_name("the qa team")).to eq("the_qa_team")
    end

    it "downcase all letters" do
      expect(Namespace.sanitize_name("QA")).to eq("qa")
    end

    it "remove unsupported chars" do
      expect(Namespace.sanitize_name("qa, developers & others")).to eq("qa_developers__others")
    end
  end

  context "global namespace" do
    it "must be public" do
      namespace = create(:namespace, global: true, public: true)
      namespace.public = false
      expect(namespace.save).to be false
    end
  end

  describe "namespace_clean_name" do
    let(:registry)    { create(:registry) }
    let(:owner)       { create(:user) }
    let(:team)        { create(:team, owners: [owner]) }
    let(:namespace)   { create(:namespace, team: team) }

    context "non global namespace" do
      it "returns the name of the namespace" do
        expect(namespace.clean_name).to eq(namespace.name)
      end
    end

    context "global namespace" do
      it "returns the name of the namespace" do
        global_namespace = create(:namespace, global: true, public: true, registry: registry)
        expect(global_namespace.clean_name).to eq(registry.hostname)
      end
    end
  end

  describe "get_from_name" do
    let!(:registry)    { create(:registry) }
    let!(:owner)       { create(:user) }
    let!(:team)        { create(:team, owners: [owner]) }
    let!(:namespace)   { create(:namespace, team: team) }
    let!(:repo)        { create(:repository, namespace: namespace) }

    it "works for global namespaces" do
      ns = Namespace.find_by(global: true)
      namespace, name = Namespace.get_from_name(repo.name)
      expect(namespace.id).to eq ns.id
      expect(name).to eq repo.name
    end

    it "works for user namespaces" do
      ns, name = Namespace.get_from_name("#{namespace.name}/#{repo.name}")
      expect(ns.id).to eq namespace.id
      expect(name).to eq repo.name
    end
  end
end
