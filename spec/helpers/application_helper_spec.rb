require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#user_image_tag" do
    # Mocking the gravatar_image_tag
    def gravatar_image_tag(email)
      email
    end

    it "uses the gravatar image tag if enabled" do
      APP_CONFIG["gravatar"] = { "enabled" => true }
      expect(user_image_tag("user@example.com")).to eq "user@example.com"
    end

    it "uses the fa icon if gravatar support is disabled" do
      APP_CONFIG["gravatar"] = { "enabled" => false }
      expect(user_image_tag("user@example.com")).to eq(
        '<img class="user-picture" src="/images/user.svg" alt="User" />')
    end
  end
end
