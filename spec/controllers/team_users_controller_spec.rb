require 'rails_helper'

describe TeamUsersController do

  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners: [ owner ],
           contributors: [ contributor ])
  end

  describe 'as an owner of the team' do
    before :each do
      sign_in owner
    end

    describe 'DELETE #destroy' do

      it 'does not allow to remove the only owner of the team' do
        delete :destroy, id: team.team_users.find_by(role: TeamUser.roles['owner']).id, format: 'js'
        expect(team.owners.exists?(owner.id)).to be true
      end

      it 'removes a team user' do
        user = create(:user)
        team.viewers << user

        delete :destroy, id: team.team_users.find_by(role: TeamUser.roles['viewer']).id, format: 'js'
        expect(team.viewers.exists?(user.id)).to be false
      end

      it 'redirects to the teams page when the user removes himself' do
        user = create(:user)
        team.owners << user

        delete :destroy, id: team.team_users.find_by(user_id: owner.id).id, format: 'js'
        expect(team.owners.exists?(owner.id)).to be false
        expect(response.body).to eq("window.location = '/teams'")
      end
    end

    describe 'PUT #update' do

      it 'does not allow to change the role of the only owner of the team' do
        put :update, id: team.team_users.find_by(role: TeamUser.roles['owner']).id,
                     team_user: { role: 'viewer' }, format: 'js'
        expect(team.owners.exists?(owner.id)).to be true
        expect(assigns(:team_user).errors.full_messages).to match_array(['Role cannot be changed for the only owner of the team'])
      end

      it 'changes the roles of a team user' do
        user = create(:user)
        team.viewers << user

        put :update, id: team.team_users.find_by(role: TeamUser.roles['viewer']).id,
                     team_user: { role: 'contributor' }, format: 'js'
        expect(team.contributors.exists?(user.id)).to be true
        expect(assigns(:team_user).errors).to be_empty
      end

      it 'forces a page reload when the current user changes his role' do
        user = create(:user)
        team.owners << user

        put :update, id: team.team_users.find_by(user_id: owner.id).id,
                     team_user: { role: 'contributor' }, format: 'js'
        expect(team.contributors.exists?(owner.id)).to be true
        expect(assigns(:team_user).errors).to be_empty
        expect(response.body).to eq("window.location = '/teams/#{team.id}'")
      end
    end

    describe 'POST #create' do
      it 'adds a new member to the team' do
        new_user = create(:user)
        post :create,
             team_user: { team: team.name, user: new_user.username, role: TeamUser.roles['owner'] },
             format: 'js'
        expect(team.owners.exists?(new_user.id)).to be true
      end

      it 'returns an error if the user is not found' do
        post :create,
             team_user: { team: team.name, user: 'ghost', role: TeamUser.roles['owner'] },
             format: 'js'
        expect(assigns(:team_user).errors.full_messages).to match_array(['User cannot be found'])
        expect(response.status).to eq 422
      end

      it 'returns an error if the user has already a role inside of the team' do
        post :create,
             team_user: { team: team.name, user: contributor.username, role: TeamUser.roles['owner'] },
             format: 'js'
        expect(assigns(:team_user).errors.full_messages).to match_array(['User has already been taken'])
        expect(response.status).to eq 422
      end
    end

  end

  describe 'as an unprivileged member of the team' do
    before :each do
      sign_in contributor
    end

    describe 'POST #create' do
      it 'raises an unauthorized access error' do
        new_user = create(:user)
        post :create,
             team_user: { team: team.name, user: new_user.username, role: TeamUser.roles['owner'] },
             format: 'js'
        expect(response.status).to eq 401
      end
    end

    describe 'DELETE #destroy' do
      it 'raises an unauthorized access error' do
        delete :destroy, id: team.team_users.find_by(role: TeamUser.roles['owner']).id, format: 'js'
        expect(response.status).to eq 401
      end
    end

    describe 'PUT #update' do
      it 'raises an unauthorized access error' do
        put :update, id: team.team_users.find_by(role: TeamUser.roles['owner']).id,
                     team_user: { role: 'viewer' }, format: 'js'
        expect(response.status).to eq 401
      end
    end
  end

end
