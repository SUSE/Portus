require 'rails_helper'

describe RepositoriesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let(:repository) { create(:repository) }

  before :each do
    sign_in user
  end

  describe 'GET #index' do

    it 'assigns all repositories as @repositories' do
      get :index, {}, valid_session
      expect(assigns(:repositories).ids).to match_array(Repository.all.ids)
    end

  end

  describe 'GET #show' do

    it 'assigns the requested repository as @repository' do
      get :show, { id: repository }, valid_session
      expect(assigns(:repository)).to eq(repository)
    end

  end

end
