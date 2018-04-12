# frozen_string_literal: true

require "rails_helper"

describe "Feature: Tags" do
  let!(:registry) { create(:registry, hostname: "registry.test.lan") }
  let!(:user) { create(:admin) }
  let!(:team) { create(:team, owners: [user], contributors: [], viewers: []) }
  let!(:namespace) { create(:namespace, team: team, name: "user") }
  let!(:repository) { create(:repository, namespace: namespace, name: "busybox") }
  let!(:tag) do
    create(:tag, name: "tag0", repository: repository, scanned: Tag.statuses[:scan_done])
  end
  let!(:vulnerability)  { create(:vulnerability, name: "CVE-1234", scanner: "clair") }
  let!(:vulnerability1) { create(:vulnerability, name: "CVE-5678", scanner: "dummy") }
  let!(:scan_result)    { create(:scan_result, tag: tag, vulnerability: vulnerability) }
  let!(:scan_result1)   { create(:scan_result, tag: tag, vulnerability: vulnerability1) }

  before do
    login_as user, scope: :user
    APP_CONFIG["security"]["dummy"]["server"] = "yeah"
  end

  it "reports vulnerabilities", js: true do
    visit tag_path(tag)

    ["dummy", "clair", "CVE-1234", "CVE-5678", "High"].each do |i|
      expect(page).to have_content(i)
    end
  end
end
