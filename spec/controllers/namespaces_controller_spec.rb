require 'rails_helper'

describe NamespacesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let(:namespace) { create(:namespace) }

  before :each do
    sign_in user
  end

  describe 'GET #index' do

    it 'assigns all namespaces as @namespaces' do
      get :index, {}, valid_session
      expect(assigns(:namespaces).ids).to match_array(Namespace.all.ids)
    end

  end

  describe 'GET #show' do

    it 'assigns the requested namespace as @namespace' do
      get :show, { id: namespace }, valid_session
      expect(assigns(:namespace)).to eq(namespace)
    end

  end

end
