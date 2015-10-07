require "rails_helper"

describe Tag do
  it { should belong_to(:repository) }

  describe "Validator" do
    let(:repo) { create(:repository) }

    it "validates the uniqueness inside of the repo" do
      Tag.create!(repository: repo)
      expect do
        Tag.create!(repository: repo)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end

    it "validates that the tag name follows the proper format" do
      ["-a", "&a"].each do |name|
        t = Tag.new(repository: repo, name: name)
        expect(t).to_not be_valid
      end

      ["a", "1", "1.0", "R2D2", "C3PO", "latest", "_valid"].each do |name|
        t = Tag.new(repository: repo, name: name)
        expect(t).to be_valid
      end
    end

    it "checks the length of the name" do
      name = (0...100).map { ("a".."z").to_a[rand(26)] }.join
      t = Tag.new(repository: repo, name: name)
      expect(t).to be_valid

      name = (0...130).map { ("a".."z").to_a[rand(26)] }.join
      t = Tag.new(repository: repo, name: name)
      expect(t).to_not be_valid
    end
  end
end
