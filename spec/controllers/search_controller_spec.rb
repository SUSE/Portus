require 'rails_helper'

RSpec.describe SearchController, type: :controller do

  let(:registry)    { create(:registry) }
  let(:user)        { create(:user) }
  let(:team)        { create(:team, owners: [ user ]) }

  before :each do
    sign_in user

    namespace = create(:namespace, team: team, registry: registry)
    @repository= create(:repository, namespace: namespace)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, search: @repository.name
      expect(response).to have_http_status(:success)

      # NOTE: we cannot test the contents of @repositories because
      # MariaDB does not update the fulltext indexes until the transaction
      # is commited. All the data created by the tests is wrapped inside of a
      # transaction by rails, so we cannot search for it.
      # http://dev.mysql.com/doc/refman/5.6/en/fulltext-restrictions.html
    end
  end

end
