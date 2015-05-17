require 'rails_helper'

describe Auth::RegistrationsController do

  let(:valid_session) { {} }

  describe 'POST #create' do

    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'defaults admin to false when omitted' do
      post :create, user: {
        'username' => 'administrator',
        'email' => 'administrator@test.com',
        'password' => '12341234',
        'password_confirmation' => '12341234'
      }
      expect(User.find_by!(username: 'administrator')).not_to be_admin
    end

    it 'handles the admin column properly' do
      post :create, user: {
        'username' => 'administrator',
        'email' =>  'administrator@test.com',
        'password' =>  '12341234',
        'password_confirmation' => '12341234',
        'admin' => true
      }
      expect(User.find_by!(username: 'administrator')).to be_admin
    end

    it 'omits the value of admin if there is already another admin' do
      create(:user, admin: true)
      post :create, user: {
        'username'=> 'wonnabeadministrator',
        'email' => 'wonnabeadministrator@test.com',
        'password' => '12341234',
        'password_confirmation' => '12341234',
        'admin' => true
      }
      expect(User.find_by!(username: 'wonnabeadministrator')).not_to be_admin
    end

  end

end
