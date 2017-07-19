require "rails_helper"

RSpec.describe CommentsHelper, type: :helper do
  let(:admin)   { create(:admin) }
  let(:author)  { create(:user) }
  let(:user)    { create(:user) }
  let(:comment) { create(:comment, author: author) }

  describe "can_destroy_comment?" do
    it "returns true if current user is the author of the comment" do
      sign_in author
      expect(helper.can_destroy_comment?(comment)).to be true
    end

    it "returns true if current user is an admin" do
      sign_in admin
      expect(helper.can_destroy_comment?(comment)).to be true
    end

    it "returns false if current user is not the author or admin" do
      sign_in user
      expect(helper.can_destroy_comment?(comment)).to be false
    end
  end
end
