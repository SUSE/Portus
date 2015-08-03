require 'rails_helper'

describe Tag do

  it { should belong_to(:repository) }
  it { should have_many(:fs_layers) }

end
