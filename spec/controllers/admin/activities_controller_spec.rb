require 'rails_helper'

RSpec.describe Admin::ActivitiesController, type: :controller do
  let(:admin) { create(:user, admin: true) }

  before :each do
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'export to csv' do
    render_views

    let(:user) { create(:user, username: 'sammy') }
    let(:another_user) { create(:user, username: 'dean') }
    let(:activity_owner) { create(:user, username: 'castiel') }
    let(:registry) { create(:registry) }
    let(:namespace) { create(:namespace, name: 'patched_images', registry: registry, team: team) }
    let(:team) { create(:team, name: 'qa', owners: [user] ) }
    let(:repository) { create(:repository, name: 'sles12', namespace: namespace) }
    let(:tag) { create(:tag, name: '1.0.0', repository: repository) }

    before :each do
      Timecop.freeze(Time.gm(2015))
      create(:activity_team_create,
             trackable_id: team.id,
             owner_id: activity_owner.id)
      create(:activity_team_add_member,
             trackable_id: team.id,
             owner_id: activity_owner.id,
             recipient_id: another_user.id,
             parameters: { role: 'viewer' })
      create(:activity_team_remove_member,
             trackable_id: team.id,
             owner_id: activity_owner.id,
             recipient_id: another_user.id,
             parameters: { role: 'viewer' })
      create(:activity_team_change_member_role,
             trackable_id: team.id,
             owner_id: activity_owner.id,
             recipient_id: another_user.id,
             parameters: { old_role: 'viewer', new_role: 'contributor' })
      create(:activity_namespace_create,
             trackable_id: namespace.id,
             owner_id: activity_owner.id)
      create(:activity_namespace_public,
             trackable_id: namespace.id,
             owner_id: activity_owner.id)
      create(:activity_namespace_private,
             trackable_id: namespace.id,
             owner_id: activity_owner.id)
      create(:activity_repository_push,
             trackable_id: tag.repository.id,
             recipient_id: tag.id,
             owner_id: activity_owner.id)

    end

    it 'generates a csv file' do
      get :index, format: :csv
      expect(response.headers).to match({
        'Content-Disposition' => "attachment; filename=\"activities.csv\"",
        'Content-Type'=>'text/csv' })

      csv = <<CSV
Tracked item,Item,Event,Recipient,Triggered by,Time,Notes
team,qa,create,-,castiel,2015-01-01 00:00:00 UTC,-
team,qa,add member,dean,castiel,2015-01-01 00:00:00 UTC,role viewer
team,qa,remove member,dean,castiel,2015-01-01 00:00:00 UTC,role viewer
team,qa,change member role,dean,castiel,2015-01-01 00:00:00 UTC,from viewer to contributor
namespace,patched_images,create,-,castiel,2015-01-01 00:00:00 UTC,owned by team qa
namespace,patched_images,make public,-,castiel,2015-01-01 00:00:00 UTC,-
namespace,patched_images,make private,-,castiel,2015-01-01 00:00:00 UTC,-
repository,patched_images/sles12:1.0.0,push tag,-,castiel,2015-01-01 00:00:00 UTC,-
CSV

      expect(response.body).to eq(csv)
    end
  end

end
