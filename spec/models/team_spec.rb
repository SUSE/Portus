require 'rails_helper'

describe Team do

  it { should belong_to(:owner).class_name(User) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owner) }
  it { should have_many(:namespaces) }

  it 'downcases the name on creation' do
    team = FactoryGirl.create(:team, name: 'TeAm')
    expect(team.name).to eq('team')
  end

end
