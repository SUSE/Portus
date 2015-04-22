require 'rails_helper'

describe RepositoriesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }

  before :each do
    sign_in user
  end

  describe 'GET #index' do

    it 'assigns all repositories as @repositories' do
      repository = create(:repository)
      get :index, {}, valid_session
      expect(assigns(:repositories)).to eq([repository])
    end

  end

  describe 'GET #show' do

    it 'assigns the requested repository as @repository' do
      repository = create(:repository)
      get :show, { id: repository.to_param }, valid_session
      expect(assigns(:repository)).to eq(repository)
    end

  end

end
