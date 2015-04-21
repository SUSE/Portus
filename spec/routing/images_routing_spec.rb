require 'rails_helper'

RSpec.describe ImagesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/images').to route_to('images#index')
    end

    it 'routes to #show' do
      expect(get: '/images/1').to route_to('images#show', id: '1')
    end
  end
end
