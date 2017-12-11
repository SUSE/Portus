# frozen_string_literal: true

require "rails_helper"

describe "search/index" do
  context "regular render" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:team)       { create(:team, owners: [user]) }
    let!(:namespace)  { create(:namespace, team: team, name: "user") }
    let!(:repository) { create(:repository, namespace: namespace, name: "busybox") }

    before do
      @teams        = Team.all
      @namespaces   = Namespace.all
      @repositories = Repository.all
    end

    # See https://github.com/SUSE/Portus/issues/1398
    it "renders the page successfully" do
      render

      section = assert_select(".panel-heading")
      expect(section.text).to eq "Search results"
    end
  end
end
