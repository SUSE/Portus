# frozen_string_literal: true

require "rails_helper"

describe TagsController do
  describe "GET #show" do
    let!(:registry)      { create(:registry, hostname: "registry.test.lan") }
    let!(:user)          { create(:admin) }
    let!(:repository)    { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag) do
      create(:tag, name: "tag0", repository: repository, scanned: Tag.statuses[:scan_done])
    end
    let!(:vulnerability) { create(:vulnerability, name: "CVE-1234", scanner: "clair") }
    let!(:scan_result)   { create(:scan_result, tag: tag, vulnerability: vulnerability) }

    before do
      sign_in user
      enable_security_vulns_module!
    end

    it "assigns the requested tag as @tag" do
      get tag_url(tag.to_param)
      expect(assigns(:tag)).to eq(tag)
      expect(response.status).to eq 200
    end
  end
end
