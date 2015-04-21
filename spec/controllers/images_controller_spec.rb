require 'rails_helper'

describe ImagesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }

  before :each do
    sign_in user
  end

  describe 'GET #index' do

    it 'assigns all images as @images' do
      image = create(:image)
      get :index, {}, valid_session
      expect(assigns(:images)).to eq([image])
    end

  end

  describe 'GET #show' do

    it 'assigns the requested image as @image' do
      image = create(:image)
      get :show, { id: image.to_param }, valid_session
      expect(assigns(:image)).to eq(image)
    end

  end

end
