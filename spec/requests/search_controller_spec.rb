# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchController do
  let(:registry)    { create(:registry) }
  let(:user)        { create(:user) }
  let(:team)        { create(:team, owners: [user]) }

  before do
    sign_in user

    namespace = create(:namespace, team: team, registry: registry)
    @repository = create(:repository, namespace: namespace)
  end

  describe "GET #index" do
    it "returns http success" do
      get search_index_url(search: @repository.name)
      expect(response).to have_http_status(:success)
    end
  end
end
