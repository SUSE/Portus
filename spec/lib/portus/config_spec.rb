# Returns a Portus::Config configured with the two given config files.
def get_config(default, local)
  default = File.join(Rails.root, "spec", "fixtures", default)
  local   = File.join(Rails.root, "spec", "fixtures", local)
  Portus::Config.new(default, local)
end

describe Portus::Config do
  it "returns an empty config if neither the global nor the local were found" do
    cfg = get_config("", "").fetch

    expect(cfg.enabled?("gravatar")).to be_falsey
    expect(cfg.enabled?("ldap")).to be_falsey
  end

  it "only uses the global if the local config was not found" do
    cfg = get_config("config.yml", "").fetch

    expect(cfg.enabled?("gravatar")).to be_truthy
    expect(cfg.enabled?("ldap")).to be_falsey
  end

  it "merges both config files and work as expected" do
    cfg = get_config("config.yml", "local.yml").fetch

    expect(cfg.enabled?("gravatar")).to be_truthy
    expect(cfg.enabled?("ldap")).to be_truthy
    expect(cfg["ldap"]["hostname"]).to eq "ldap.example.com"
    expect(cfg["ldap"]["port"]).to eq 389
    expect(cfg["ldap"]["base"]).to eq "ou=users,dc=example,dc=com"
  end

  it "raises an error when the local file is badly formatted" do
    bad   = get_config("config.yml", "bad.yml")
    expect { bad.fetch }.to raise_error(StandardError, "Wrong format for the config-local file!")
  end
end
