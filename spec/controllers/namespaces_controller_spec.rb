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
    before { User.create_portus_user! }

    let(:portus) { User.find_by(username: "portus") }

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

  describe "PUT #change_visibility" do
    # users may change the visibility of their personal namespace
    context "when option user_permission.change_visibility is enabled" do
      before do
        APP_CONFIG["user_permission"]["change_visibility"]["enabled"] = true
      end

      it "allows the user to change the visibility attribute" do
        sign_in owner
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :js

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end

      it "allows the user to change the visibility attribute [json]" do
        sign_in owner
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :json

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end
    end

    # only admins may change the visibility of a user's personal namespace
    context "when option user_permission.change_visibility is disabled" do
      before do
        APP_CONFIG["user_permission"]["change_visibility"]["enabled"] = false
      end

      it "prohibits the user from changing the visibility attribute" do
        sign_in owner
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :js

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_private")
        expect(response.status).to eq 401
      end

      it "prohibits the user from changing the visibility attribute [json]" do
        sign_in owner
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :json

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_private")
        expect(response.status).to eq 401
      end

      it "allows an admin to change the visibility attribute" do
        sign_in admin
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :js

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end

      it "allows an admin to change the visibility attribute [json]" do
        sign_in admin
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :json

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end

      it "allows an admin to change the visibility attribute" do
        sign_in admin
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :js

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end

      it "allows an admin to change the visibility attribute [json]" do
        sign_in admin
        put :change_visibility,
            id:         owner.namespace.id,
            visibility: "visibility_public",
            format:     :json

        owner.namespace.reload
        expect(owner.namespace.visibility).to eq("visibility_public")
        expect(response.status).to eq 200
      end
    end

    it "allows the owner of the team to change the visibility attribute" do
      sign_in owner
      put :change_visibility,
          id:         namespace.id,
          visibility: "visibility_public",
          format:     :js

      namespace.reload
      expect(namespace.visibility).to eq("visibility_public")
      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      put :change_visibility,
          id:         namespace.id,
          visibility: "visibility_public",
          format:     :js

      expect(response.status).to eq 401
    end
  end

  describe "PATCH #update" do
    it "does not allow to change the description by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch :update, id: namespace.id, namespace: { description: "descripti0n" },
        format: :json
      expect(response.status).to eq(401)
    end

    context "non-admins are allowed to update namespaces" do
      it "does allow to change the description by owners" do
        sign_in owner
        patch :update, id: namespace.id, namespace: { description: "descripti0n" },
          format: :json
        expect(response.status).to eq(200)
      end

      it "changes the team if needed" do
        team2 = create(:team)
        sign_in owner
        patch :update, id: namespace.id, namespace: { team: team2.name }, format: :json
        expect(response.status).to eq(200)
        expect(namespace.reload.team.id).to eq team2.id
      end
    end

    context "non-admins are not allowed to update namespaces" do
      before do
        APP_CONFIG["user_permission"]["manage_namespace"]["enabled"] = false
      end

      it "does not allow to change the description by owners" do
        sign_in owner
        patch :update, id: namespace.id, namespace: { description: "descripti0n" }, format: :json
        expect(response.status).to eq(401)
        expect(namespace.reload.description).to eq "short test description"
      end

      it "does not change the team" do
        team2 = create(:team)
        sign_in owner
        patch :update, id: namespace.id, namespace: { team: team2.name }, format: :json
        expect(response.status).to eq(401)
        expect(namespace.reload.team.id).to eq team.id
      end
    end

    it "does not allow to change the team to viewers" do
      sign_out user

      sign_in viewer
      patch :update, id: namespace.id, namespace: { team: team.name + "o" }, format: :json
      expect(response.status).to eq(401)
    end

    it "does nothing if you try to change to a non-existing team" do
      sign_in owner
      patch :update, id: namespace.id, namespace: { team: "unknown" }, format: :json
      expect(response.status).to eq(422)
      expect(namespace.reload.team.id).to eq team.id
    end
  end

  describe "typeahead" do
    render_views

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

  describe "activity tracking" do
    before do
      sign_in owner
    end

    it "tracks set namespace private" do
      namespace.update_attributes(visibility: Namespace.visibilities[:visibilty_public])

      expect do
        put :change_visibility,
            id:         namespace.id,
            visibility: "visibility_private",
            format:     :js
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("namespace.change_visibility")
      expect(activity.parameters[:visibility]).to eq("visibility_private")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(namespace)
    end

    it "tracks set namespace protected" do
      namespace.update_attributes(visibility: Namespace.visibilities[:visibilty_public])

      expect do
        put :change_visibility,
            id:         namespace.id,
            visibility: "visibility_protected",
            format:     :js
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("namespace.change_visibility")
      expect(activity.parameters[:visibility]).to eq("visibility_protected")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(namespace)
    end

    it "tracks set namespace public" do
      namespace.update_attributes(visibility: Namespace.visibilities[:visibility_private])

      expect do
        put :change_visibility,
            id:         namespace.id,
            visibility: "visibility_public",
            format:     :js
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("namespace.change_visibility")
      expect(activity.parameters[:visibility]).to eq("visibility_public")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(namespace)
    end

    context "non-admins are allowed to update namespaces" do
      it "tracks editing of a namespace description" do
        old_description = namespace.description
        expect do
          patch :update, id: namespace.id, namespace: { description: "descripti0n" },
            format: :json
        end.to change(PublicActivity::Activity, :count).by(1)

        namespace_description_activity = PublicActivity::Activity.find_by(
          key: "namespace.change_namespace_description"
        )
        expect(namespace_description_activity.owner).to eq(owner)
        expect(namespace_description_activity.trackable).to eq(namespace)
        expect(namespace_description_activity.parameters[:old]).to eq(old_description)
        expect(namespace_description_activity.parameters[:new]).to eq("descripti0n")
      end

      it "tracks change team" do
        team2 = create(:team)
        expect do
          patch :update, id: namespace.id, namespace: { team: team2.name }, format: :json
        end.to change(PublicActivity::Activity, :count).by(1)
        namespace_change_team_activity = PublicActivity::Activity.find_by(
          key: "namespace.change_team"
        )
        expect(namespace_change_team_activity.owner).to eq(owner)
        expect(namespace_change_team_activity.trackable).to eq(namespace)
        expect(namespace_change_team_activity.parameters[:old]).to eq(team.id)
        expect(namespace_change_team_activity.parameters[:new]).to eq(team2.id)
      end
    end

    context "non-admins are not allowed to update namespaces" do
      before do
        APP_CONFIG["user_permission"]["manage_namespace"]["enabled"] = false
      end

      it "does not track editing of a namespace description" do
        expect do
          patch :update, id: namespace.id, namespace: { description: "descripti0n" },
            format: :json
        end.to change(PublicActivity::Activity, :count).by(0)
      end

      it "does not tracks change team" do
        team2 = create(:team)
        expect do
          patch :update, id: namespace.id, namespace: { team: team2.name }, format: :json
        end.to change(PublicActivity::Activity, :count).by(0)
      end
    end
  end
end
