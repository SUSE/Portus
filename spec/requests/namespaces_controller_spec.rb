# frozen_string_literal: true

require "rails_helper"

describe NamespacesController do
  let(:registry) { create(:registry) }
  let(:user) { create(:user) }
  let(:viewer) { create(:user) }
  let(:contributor) { create(:user) }
  let(:owner) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:team) do
    create(:team,
           owners:       [owner],
           viewers:      [user, viewer],
           contributors: [contributor])
  end
  let(:namespace) do
    create(
      :namespace,
      team:        team,
      description: "short test description",
      registry:    registry
    )
  end

  before do
    # trigger creation of registry
    registry
    sign_in user
  end

  describe "GET #index" do
    it "renders index template successfully [html]" do
      get namespaces_url

      expect(response).to render_template(:index)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show" do
    before { User.create_portus_user! }

    let(:portus) { User.find_by(username: "portus") }

    it "allows team members to view the page" do
      sign_in owner
      get namespace_url(id: namespace.id)

      expect(assigns(:namespace)).to eq(namespace)
      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      get namespace_url(id: namespace.id)

      expect(response.status).to eq 401
    end

    it "does not show the namespace for the portus user" do
      sign_in create(:user)

      expect do
        get namespace_url(id: portus.namespace.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "typeahead" do
    context "when admin" do
      it "does allow to search for all the valid teams" do
        create(:team, name: "testing", owners: [admin])
        create(:team, name: "testing2", owners: [owner])

        sign_in admin
        get namespaces_typeahead_url(query: "test"), params: { format: :json }

        expect(response.status).to eq(200)
        result = JSON.parse(response.body)
        expect(result.length).to eq(2)
        expect(result[0]["name"]).to eq("testing")
        expect(result[1]["name"]).to eq("testing2")
      end
    end

    context "when regular user" do
      it "does allow to search for valid teams by owner" do
        testing_team = create(:team, name: "testing", owners: [owner])
        sign_in owner
        get namespaces_typeahead_url(query: "test"), params: { format: :json }
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)
        expect(teamnames.length).to eq(1)
        expect(teamnames[0]["name"]).to eq(testing_team.name)
      end

      it "does not allow to search by viewers" do
        create(:team, name: "testing", owners: [owner], viewers: [viewer])
        sign_in viewer
        get namespaces_typeahead_url(query: "test"), params: { format: :json }
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)
        expect(teamnames.length).to eq(0)
      end

      it "prevents XSS attacks" do
        create(:team, name: "<script>alert(1)</script>", owners: [owner])

        sign_in owner
        get namespaces_typeahead_url(query: "<"), params: { format: :json }
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)

        expect(teamnames[0]["name"]).to eq("alert(1)")
      end
    end
  end
end
