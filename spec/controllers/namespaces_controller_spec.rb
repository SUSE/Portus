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

describe NamespacesController, type: :controller do
  let(:valid_session) { {} }
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
      get :index, valid_session

      expect(response).to render_template(:index)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show" do
    let!(:portus) { create(:admin, username: "portus") }

    it "paginates repositories" do
      sign_in owner
      get :show, id: namespace.id

      expect(assigns(:repositories)).to respond_to(:total_pages)
    end

    it "allows team members to view the page" do
      sign_in owner
      get :show, id: namespace.id

      expect(assigns(:namespace)).to eq(namespace)
      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      get :show, id: namespace.id

      expect(response.status).to eq 401
    end

    it "does not show the namespace for the portus user" do
      sign_in create(:user)

      expect do
        get :show, id: portus.namespace.id
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "typeahead" do
    render_views

    context "when admin" do
      it "does allow to search for all the valid teams" do
        create(:team, name: "testing", owners: [admin])
        create(:team, name: "testing2", owners: [owner])

        sign_in admin
        get :typeahead, query: "test", format: :json

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
        get :typeahead, query: "test", format: :json
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)
        expect(teamnames.length).to eq(1)
        expect(teamnames[0]["name"]).to eq(testing_team.name)
      end

      it "does not allow to search by viewers" do
        create(:team, name: "testing", owners: [owner], viewers: [viewer])
        sign_in viewer
        get :typeahead, query: "test", format: :json
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)
        expect(teamnames.length).to eq(0)
      end

      it "prevents XSS attacks" do
        create(:team, name: "<script>alert(1)</script>", owners: [owner])

        sign_in owner
        get :typeahead, query: "<", format: :json
        expect(response.status).to eq(200)
        teamnames = JSON.parse(response.body)

        expect(teamnames[0]["name"]).to eq("alert(1)")
      end
    end
  end
end
