require 'rails_helper'

RSpec.describe Registry, type: :model do

  it { should have_many(:namespaces) }
end
