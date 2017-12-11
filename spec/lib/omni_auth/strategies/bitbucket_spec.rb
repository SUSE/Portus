# frozen_string_literal: true

require "rails_helper"

describe OmniAuth::Strategies::Bitbucket do
  subject { described_class.new({}) }

  let(:access_token) { instance_double("AccessToken", options: {}) }
  let(:parsed_response) { instance_double("ParsedResponse") }
  let(:response) { instance_double("Response", parsed: parsed_response) }

  context "get user data" do
    let(:parsed_mails) { instance_double("ParsedResponse") }
    let(:response_mails) { instance_double("Response", parsed: parsed_mails) }
    let(:info) { { name: "User", nickname: "user", email: "test@mail.net" } }

    before do
      expect(access_token).to receive(:get).with("/api/2.0/user").and_return(response)
      expect(subject).to receive(:access_token).and_return(access_token).at_least(:once)
    end

    context "#info" do
      it "returns user info" do
        expect(parsed_response).to receive(:[]).and_return("User", "user").twice
        expect(parsed_mails).to receive(:[]).and_return(
          [{ "email" => "test@mail.net", "is_primary" => true, "is_confirmed" => true }]
        )
        expect(access_token).to receive(:get).with("/api/2.0/user/emails")
                                             .and_return(response_mails)
        expect(subject.info).to eql info
      end
    end

    context "#extra" do
      it "returns extra user info" do
        expect(subject.extra[:raw_info]).to eql parsed_response
      end
    end
  end

  context "#callback_url" do
    it "return callback url" do
      expect(subject).to receive(:full_host).and_return("http://test.net")
      expect(subject).to receive(:script_name).and_return("")
      expect(subject.callback_url).to eql "http://test.net/users/auth/bitbucket/callback"
    end
  end

  context "#build_access_token_with_team_check" do
    before do
      expect(subject).to receive(:build_access_token_without_team_check).and_return(access_token)
    end

    it "without team setting return access_token" do
      expect(subject.build_access_token_with_team_check).to eql access_token
    end

    context "with team setting" do
      # let(:parsed_response) { instance_double("ParsedResponse") }
      # let(:response_mails) { instance_double("Response", parsed: parsed_mails) }
      before do
        expect(parsed_response).to receive(:[]).with("values")
                                               .and_return([{ "username" => "test-team" }])
        expect(access_token).to receive(:get).with("/api/2.0/teams?role=member")
                                             .and_return(response)
      end

      it "when team match, return access_token" do
        subject.options.team = "test-team"
        expect(subject.build_access_token_with_team_check).to eql access_token
      end

      it "when team doesn't match, raise error" do
        subject.options.team = "wrong-team"
        expect { subject.build_access_token_with_team_check }.to raise_error(
          OmniAuth::Strategies::OAuth2::CallbackError
        )
      end
    end
  end
end
