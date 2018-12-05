# frozen_string_literal: true

# == Schema Information
#
# Table name: namespaces
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer
#  registry_id :integer          not null
#  global      :boolean          default(FALSE)
#  description :text(65535)
#  visibility  :integer
#
# Indexes
#
#  index_namespaces_on_name_and_registry_id  (name,registry_id) UNIQUE
#  index_namespaces_on_registry_id           (registry_id)
#  index_namespaces_on_team_id               (team_id)
#

require "rails_helper"

describe Namespace do
  it { is_expected.to have_many(:repositories) }
  it { is_expected.to belong_to(:team) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to allow_value("test1", "1test", "another-test").for(:name) }
  it { is_expected.not_to allow_value("TesT1", "1Test", "another_test!").for(:name) }

  context "validator" do
    let(:registry)    { create(:registry) }
    let(:owner)       { create(:user) }
    let(:team)        { create(:team, owners: [owner]) }
    let(:namespace)   { create(:namespace, team: team) }

    it "checks for the uniqueness of the namespace inside of the registry" do
      described_class.create!(team: team, registry: registry, name: "lala")
      expect do
        described_class.create!(team: team, name: "lala", registry: registry)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end

    it "checks tat the namespace name follows the proper format" do
      ["-a", "&a", "_invalid", "R2D2", "also_invalid_"].each do |name|
        n = described_class.new(team: team, registry: registry, name: name)
        expect(n).not_to be_valid
      end

      ["a", "1", "1.0", "r2d2", "thingie", "is_valid"].each do |name|
        n = described_class.new(team: team, registry: registry, name: name)
        expect(n).to be_valid
      end
    end

    it "checks the length of the name" do
      name = (0...100).map { ("a".."z").to_a[rand(26)] }.join
      n = described_class.new(team: team, registry: registry, name: name)
      expect(n).to be_valid

      name = (0...270).map { ("a".."z").to_a[rand(26)] }.join
      n = described_class.new(team: team, registry: registry, name: name)
      expect(n).not_to be_valid
    end
  end

  context "is portus" do
    let!(:registry) { create(:registry) }
    let!(:owner)    { create(:user) }
    let(:portus)    { User.find_by(username: "portus") }

    before { User.create_portus_user! }

    it "returns true when the given namespace belongs to portus" do
      expect(described_class.find_by(name: portus.username)).to be_portus
      expect(described_class.find_by(name: owner.username)).not_to be_portus
    end

    it "only returns the namespaces that are not portus" do
      # The registry creates one extra user, so we have two personal
      # namespace. Furthermore, there's the global one.
      expect(described_class.not_portus.count).to eq 3
      expect(described_class.count).to eq 4
    end
  end

  context "global namespace" do
    it "cannot be private" do
      namespace = create(
        :namespace,
        global:     true,
        visibility: described_class.visibilities[:visibility_public]
      )
      namespace.visibility = described_class.visibilities[:visibility_private]
      expect(namespace.save).to be false

      namespace.visibility = described_class.visibilities[:visibility_protected]
      expect(namespace.save).to be true
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
        global_namespace = create(
          :namespace,
          global:     true,
          visibility: described_class.visibilities[:visibility_public],
          registry:   registry
        )
        expect(global_namespace.clean_name).to eq(registry.hostname)
      end
    end
  end

  describe "get_from_repository_name" do
    let!(:registry)    { create(:registry) }
    let!(:owner)       { create(:user) }
    let!(:team)        { create(:team, owners: [owner]) }
    let!(:namespace)   { create(:namespace, team: team, registry: registry) }
    let!(:repo)        { create(:repository, namespace: namespace) }

    it "works for global namespaces" do
      ns = described_class.find_by(global: true)
      namespace, name = described_class.get_from_repository_name(repo.name)
      expect(namespace.id).to eq ns.id
      expect(name).to eq repo.name
    end

    it "works for user namespaces" do
      ns, name = described_class.get_from_repository_name("#{namespace.name}/#{repo.name}")
      expect(ns.id).to eq namespace.id
      expect(name).to eq repo.name
    end

    context "when providing a registry" do
      it "works for global namespaces" do
        ns = described_class.find_by(global: true)
        namespace, name = described_class.get_from_repository_name(repo.name, registry)
        expect(namespace.id).to eq ns.id
        expect(name).to eq repo.name
      end

      it "works for user namespaces" do
        repository_name = "#{namespace.name}/#{repo.name}"
        ns, name = described_class.get_from_repository_name(repository_name, registry)
        expect(ns.id).to eq namespace.id
        expect(name).to eq repo.name
      end
    end
  end

  describe "make_valid" do
    let!(:team)      { create(:team) }
    let!(:namespace) { create(:namespace, team: team) }

    it "does nothing on already valid names" do
      ["name", "a", "a_a", "45", "n4", "h2o", "flavio.castelli"].each do |name|
        expect(described_class.make_valid(name)).to eq name
      end
    end

    it "returns nil if the name cannot be changed" do
      ["", ".", "_", "-", "!!!!"].each do |name|
        expect(described_class.make_valid(name)).to be_nil
      end
    end

    it "changes invalid names that can be saved" do
      expect(described_class.make_valid("_name")).to eq "name"
      expect(described_class.make_valid("name_")).to eq "name"
      expect(described_class.make_valid("___name_-aa__")).to eq "name_aa"
      expect(described_class.make_valid("_ma._.n")).to eq "ma_n"
      expect(described_class.make_valid("ma_s")).to eq "ma_s"
      expect(described_class.make_valid("!lol!")).to eq "lol"
      expect(described_class.make_valid("!lol!name")).to eq "lol_name"
      expect(described_class.make_valid("Miquel.Sabate")).to eq "miquel.sabate"
      expect(described_class.make_valid("Miquel.Sabate.")).to eq "miquel.sabate"
      expect(described_class.make_valid("M")).to eq "m"
      expect(described_class.make_valid("_M_")).to eq "m"
    end

    it "adds an increment if a team with the name already exists" do
      expect(described_class.make_valid(namespace.name)).to eq "#{namespace.name}0"

      create(:namespace, name: "#{namespace.name}0", team: team)
      expect(described_class.make_valid(namespace.name)).to eq "#{namespace.name}1"
    end
  end
end
