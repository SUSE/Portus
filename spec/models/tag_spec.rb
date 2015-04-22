require 'rails_helper'

describe Tag do

  it { should belong_to(:repository) }

end
