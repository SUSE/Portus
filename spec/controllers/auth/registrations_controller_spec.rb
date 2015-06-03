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

  describe 'PUT #update' do

    let!(:user) { create(:user, admin: true) }

    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it 'does not allow invalid emails' do
      email = User.find(user.id).email
      put :update, user: { 'email' => 'invalidone' }
      expect(User.find(user.id).email).to eq(email)
      put :update, user: { 'email' => 'valid@example.com' }
      expect(User.find(user.id).email).to eq('valid@example.com')
    end

    it 'changes the Gravatar settings accordingly' do
      expect(User.find(user.id).gravatar?).to be true
      put :update, user: { 'gravatar' => 0 }
      expect(User.find(user.id).gravatar?).to be false
      put :update, user: { 'gravatar' => 1 }
      expect(User.find(user.id).gravatar?).to be true
    end

    # NOTE: since the tests on passwords also have to take care that even if
    # there are other parameters (e.g. emails), they are ignored when there are
    # password parameters, these tests will always have an extra parameter.

    it 'does not allow empty passwords' do
      put :update, user: {
        'email' => 'user@example.com',
        'current_password' => 'test-password',
        'password' => '',
        'password_confirmation' => ''
      }
      expect(User.find(user.id).valid_password?('test-password')).to be true
    end

    it 'checks that the old password is ok' do
      put :update, user: {
        'email' => 'user@example.com',
        'current_password' => 'test-passwor',
        'password' => 'new-password',
        'password_confirmation' => 'new-password'
      }
      expect(User.find(user.id).valid_password?('test-password')).to be true
    end

    it 'checks that the new password and its confirmation match' do
      put :update, user: {
        'email' => 'user@example.com',
        'current_password' => 'test-password',
        'password' => 'new-password',
        'password_confirmation' => 'new-passwor'
      }
      expect(User.find(user.id).valid_password?('test-password')).to be true
    end

    it 'changes the password when everything is alright' do
      put :update, user: {
        'email' => 'user@example.com',
        'current_password' => 'test-password',
        'password' => 'new-password',
        'password_confirmation' => 'new-passwor'
      }
      expect(User.find(user.id).valid_password?('test-password')).to be true
    end

  end

end
