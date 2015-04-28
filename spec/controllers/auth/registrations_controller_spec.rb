require 'rails_helper'

describe Auth::RegistrationsController do

  let(:valid_session) { {} }

  describe 'POST #create' do

    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'defaults admin to false when omitted' do
      post :create, user: {
        username: 'portus',
        email: 'portus@test.com',
        password: '12341234',
        'password_confirmation': '12341234'
      }
      assert !User.find_by!(username: 'portus').admin
    end

    it 'handles the admin column properly' do
      post :create, user: {
        username: 'portus',
        email: 'portus@test.com',
        password: '12341234',
        'password_confirmation': '12341234',
        admin: true
      }
      assert User.find_by!(username: 'portus').admin
    end

    it 'omits the value of admin if there is already another admin' do
      create(:user, admin: true)
      post :create, user: {
        username: 'portus',
        email: 'portus@test.com',
        password: '12341234',
        'password_confirmation': '12341234',
        admin: true
      }
      assert !User.find_by!(username: 'portus').admin
    end

  end

end
