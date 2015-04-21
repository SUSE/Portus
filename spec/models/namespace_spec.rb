require 'rails_helper'

describe Namespace do

  it { should have_many(:repositories) }
  it { should belong_to(:team) }
  it { should validate_presence_of(:name) }

end
