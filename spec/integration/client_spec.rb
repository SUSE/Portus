require "integration/helper"
require "portus/registry_client"

def push_test_images
  name = ldap? ? "johnldap" : "john"
  email = "john@example.com"
  password = "12341234"
  create_user(name, email, password, true)
  expect { login(name, password, email) }.not_to raise_error

  # Pulling images that we should already have (so we go faster :P). Then
  # re-tag it so they can be pushed. The re-tag has another name, to avoid
  # clashes with other tests.
  name        = "registry"
  retag       = "registre"
  pulled_tags = ["2.3.1", "2.4.0", "latest"]
  pulled_tags.each do |tag|
    base  = "#{name}:#{tag}"
    tgt   = "#{retag}:#{tag}"
    img   = "library/#{base}"
    pull(img)
    system("docker tag #{img} #{registry_hostname}/#{tgt}")
  end

  expect(push("#{registry_hostname}/#{retag}")).to be_truthy

  # Wait until the registry has everything we need.
  eventually_expect(3) do
    tags = rails_exec("Tag.where(repository: Repository.find_by(name: '#{retag}')).to_json")
    tags.size
  end
end

integration "Client" do
  it "tells that a registry is reachable" do
    client = Portus::RegistryClient.new(registry_hostname)
    expect(client.reachable?).to be_truthy
  end

  it "fetches the catalog of pushed repositories" do
    push_test_images

    client = Portus::RegistryClient.new(registry_hostname)
    cat = client.catalog
    expected = { "registre" => ["2.3.1", "2.4.0", "latest"] }

    cat.each do |r|
      key = expected[r["name"]]
      next if key.nil?
      expect(key).to eq r["tags"]
    end
  end

  it "fetches the manifest of the given repo/tag" do
    push_test_images

    client = Portus::RegistryClient.new(registry_hostname)
    manifest = client.manifest("registre", "2.3.1")

    expect(manifest["name"]).to eq "registre"
    expect(manifest["tag"]).to eq "2.3"
  end
end
