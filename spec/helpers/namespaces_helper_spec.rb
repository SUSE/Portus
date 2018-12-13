# frozen_string_literal: true

require "rails_helper"

RSpec.describe NamespacesHelper, type: :helper do
  describe "known activity" do
    let!(:registry) { create(:registry) }
    let!(:user)     { create(:admin) }
    let!(:team)     { create(:team, owners: [user]) }
    let!(:namespace) do
      Namespaces::BuildService.new(user, name: "name", team: team.name).execute
    end

    it "returns 'the' plus a link when the resource is available" do
      Namespaces::CreateService.new(user, namespace).execute
      activity = PublicActivity::Activity.first

      # Namespace
      text = render_namespace_name(activity)
      expect(text).to eq "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>"

      # Team
      text = render_namespace_team(activity)
      expect(text).to eq "<span>the </span><a href=\"/teams/#{team.id}\">#{team.name}</a>"
    end

    it "returns 'the' without a link when the resource is not available" do
      Namespaces::CreateService.new(user, namespace).execute
      Namespace.find(namespace.id).delete_by!(user)
      activity = PublicActivity::Activity.find_by(key: "namespace.create")

      # Namespace
      text = render_namespace_name(activity)
      expect(text).to eq "<strong>name</strong>"

      # Team
      text = render_namespace_team(activity)
      expect(text).to eq "<span>the </span><strong>#{team.name}</strong>"
    end
  end

  describe "unknown activity (i.e. backwards compatibility)" do
    let!(:registry) { create(:registry) }
    let!(:user) { create(:admin) }

    it "simply returns 'a' on unknown namespace activity" do
      ::Teams::CreateService.new(user, name: "team").execute
      PublicActivity::Activity.all.update_all(parameters: nil)
      activity = PublicActivity::Activity.first

      expect(render_namespace_name(activity)).to eq "a"
      expect(render_namespace_team(activity)).to eq "<span>a</span>"
    end
  end
end
