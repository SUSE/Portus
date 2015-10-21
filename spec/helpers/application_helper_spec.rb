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

  describe "#activity_time_tag" do
    def time_tag(first, second, _args)
      "#{first}-#{second}"
    end

    it "uses the time_tag" do
      t = Time.zone.now
      expect(activity_time_tag(t)).to eq "#{t}-less than a minute"
    end
  end
end
