require 'rails_helper'

describe Repository do

  it { should have_many(:images) }
  it { should belong_to(:team) }
  it { should validate_presence_of(:name) }

end
