# frozen_string_literal: true

require "rails_helper"

describe HelpController do
  describe "GET #index" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }

    before do
      sign_in user
    end

    it "returns the page successfully" do
      get help_index_url
      expect(response.code.to_i).to eq 200
    end
  end
end
