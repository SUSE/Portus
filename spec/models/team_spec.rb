require 'rails_helper'

describe Team do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owners) }
  it { should have_many(:namespaces) }

  it 'checks whether the given name is downcased or not' do
    expect { FactoryGirl.create(:team, name: 'TeAm') }.to raise_error(ActiveRecord::RecordNotSaved)
    expect { FactoryGirl.create(:team, name: 'team') }.not_to raise_error
  end

  it 'Counts all the non special teams' do
    # The registry does not count.
    # NOTE: the registry factory also creates a user.
    create(:registry)
    expect(Team.all_non_special).to be_empty
    expect(Team.count).to be(2)

    # Creating a proper team, this counts.
    create(:team, owners: [User.first])
    expect(Team.all_non_special.count).to be(1)
    expect(Team.count).to be(3)

    # Personal namespaces don't count.
    user = create(:user)
    user.create_personal_namespace!
    expect(Team.all_non_special.count).to be(1)
    expect(Team.count).to be(4)
  end
end
