require 'rails_helper'

describe FsLayer do

  it { should validate_presence_of(:blob_sum) }
  it { should belong_to(:tag) }

end
