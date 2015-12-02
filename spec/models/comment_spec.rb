require "rails_helper"

describe Comment do
  it { should belong_to(:repository) }
  it { should belong_to(:author) }

  it "has a valid factory" do
    expect { Factory.build(:comment).to be_valid }
  end
end
