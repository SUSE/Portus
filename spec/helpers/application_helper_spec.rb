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
        '<i class="fa fa-user user-picture"></i>'
      )
    end

    it "uses the fa icon if the user had no email set" do
      APP_CONFIG["gravatar"] = { "enabled" => false }
      expect(user_image_tag("")).to eq(
        '<i class="fa fa-user user-picture"></i>'
      )
      expect(user_image_tag(nil)).to eq(
        '<i class="fa fa-user user-picture"></i>'
      )
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

  describe "#team_description_markdown" do
    it "renders markdown to html" do
      headline1 = "# testing"
      expect(markdown(headline1)).to eq "<h1>testing</h1>\n"
    end

    it "does not allow pictures" do
      picture = "![Alternativer Text](/pfad/zum/bild.jpg)"
      expect(markdown(picture)).to eq "<p>![Alternativer Text](/pfad/zum/bild.jpg)</p>\n"
    end

    it "does not allow styles" do
      style = "Hello <style> foo { bar: baz; } </style> !"
      expect(markdown(style)).not_to match(/<style>/i)
    end

    it "allows only safe links" do
      link = "[IRC](irc://chat.freenode.org/#freenode)"
      expect(markdown(link)).to eq "<p>[IRC](irc://chat.freenode.org/#freenode)</p>\n"
    end

    it "filters html" do
      html_tag = "<script>alert('foo');</script>"
      expect(markdown(html_tag)).to eq "<p>alert(&#39;foo&#39;);</p>\n"
    end
  end

  describe "#signup_enabled?" do
    it "tells when signup is enabled and when it's not" do
      APP_CONFIG["signup"] = { "enabled" => true }
      APP_CONFIG["ldap"]   = { "enabled" => false }
      expect(signup_enabled?).to be_truthy

      APP_CONFIG["ldap"] = { "enabled" => true }
      expect(signup_enabled?).to be_falsey

      APP_CONFIG["signup"] = { "enabled" => false }
      expect(signup_enabled?).to be_falsey

      APP_CONFIG["ldap"] = { "enabled" => false }
      expect(signup_enabled?).to be_falsey
    end
  end

  describe "#show_first_user_alert?" do
    it "shows the first_user alert when needed" do
      APP_CONFIG["ldap"]             = { "enabled" => true }
      APP_CONFIG["first_user_admin"] = { "enabled" => true }
      expect(show_first_user_alert?).to be_truthy

      APP_CONFIG["first_user_admin"] = { "enabled" => false }
      expect(show_first_user_alert?).to be_falsey

      APP_CONFIG["ldap"] = { "enabled" => false }
      expect(show_first_user_alert?).to be_falsey

      APP_CONFIG["first_user_admin"] = { "enabled" => true }
      expect(show_first_user_alert?).to be_falsey

      create(:admin)
      APP_CONFIG["ldap"]             = { "enabled" => true }
      APP_CONFIG["first_user_admin"] = { "enabled" => true }
      expect(show_first_user_alert?).to be_falsey
    end
  end
end
