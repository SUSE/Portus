require "rails_helper"

describe Star do

  it { should belong_to(:repository) }
  it { should belong_to(:user) }

  it "validates that a user does not star the same repository twice" do
    author = create(:user)
    repository = create(:repository)

    expect { FactoryGirl.create(:star, user: author, repository: repository) }.not_to raise_error
    expect do
      FactoryGirl.create(:star, user: author, repository: repository)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

end
