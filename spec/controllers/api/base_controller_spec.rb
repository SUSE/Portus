require 'rails_helper'

describe Api::BaseController do

  controller do

    def ping
      raise Registry::AuthScope::ResourceIsNotDefined
    end

    def pong
      raise Registry::AuthScope::ResourceIsNotFound
    end

  end

  describe '.?deny_access' do

    it 'catched when Registry::AuthScope::ResourceIsNotDefined raised' do
      get :ping
      expect(controller).to receive(:deny_access)
    end

  end

end
