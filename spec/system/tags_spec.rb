# frozen_string_literal: true

require "rails_helper"

describe "Feature: Tags", js: true do
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
  let!(:vulnerability2) do
    create(:vulnerability,
           severity:    "Medium",
           name:        "CVE-5679",
           scanner:     "dummy",
           description: "Vulnerability description")
  end
  let!(:scan_result)    { create(:scan_result, tag: tag, vulnerability: vulnerability) }
  let!(:scan_result1)   { create(:scan_result, tag: tag, vulnerability: vulnerability1) }
  let!(:scan_result2)   { create(:scan_result, tag: tag, vulnerability: vulnerability2) }

  before do
    APP_CONFIG["security"]["dummy"]["server"] = "yeah"
    login_as user, scope: :user
    visit tag_path(tag)
  end

  it "reports vulnerabilities" do
    expect(page).to have_content("Vulnerabilities for tag #{tag.name} of #{tag.namespace.name}"\
      "/#{tag.repository.name}")
    ["Dummy", "Clair", "CVE-1234", "CVE-5678", "High"].each do |i|
      expect(page).to have_content(i)
    end
  end

  it "expands vulnerability details" do
    toggles = all(".toggle-details")
    toggles.first.click
    toggles.last.click

    expect(page).to have_content("Vulnerability description")
    expect(page).to have_content("No description provided")
  end

  it "shows summary of vulnerabilities" do
    expect(page).to have_content("We have detected 3 vulnerabilities")
    expect(page).to have_content("1 Medium-level vulnerabilities")
    expect(page).to have_content("2 High-level vulnerabilities")
  end

  it "shows namespace and repository links" do
    expect(page).to have_link(namespace.name)
    expect(page).to have_link(repository.name)
  end
end
