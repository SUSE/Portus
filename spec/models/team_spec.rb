require 'rails_helper'

describe Team do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owners) }
  it { should have_many(:namespaces) }

  it 'checks whether the given name is downcased or not' do
    expect { FactoryGirl.create(:team, name: 'TeAm') }.to raise_error(ActiveRecord::RecordNotSaved)
    expect { FactoryGirl.create(:team, name: 'team') }.not_to raise_error
  end

end
