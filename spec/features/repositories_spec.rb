# frozen_string_literal: true

require "rails_helper"

def find_tag_checkbox(name)
  tag = find("div", text: /\A#{name}\z/)
  tag.find(:xpath, "../..").find("input[type='checkbox']")
end

describe "Repositories support" do
  let!(:registry) { create(:registry, hostname: "registry.test.lan") }
  let!(:user) { create(:admin) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [user2], viewers: [user3]) }
  let!(:namespace) { create(:namespace, team: team, name: "user") }
  let!(:repository) { create(:repository, namespace: namespace, name: "busybox") }
  let!(:starred_repo) { create(:repository, namespace: namespace) }
  let!(:star) { create(:star, user: user, repository: starred_repo) }

  before do
    login_as user, scope: :user
  end

  describe "repository#index", js: true do
    before do
      create_list(:repository, 15, namespace: namespace)
    end

    it "Repositories table sorting is reachable through url" do
      # sort asc
      visit repositories_path(sort_asc: true)

      expect(page).to have_css(".fa-sort-amount-asc")

      # sort desc
      visit repositories_path(sort_asc: false)

      expect(page).to have_css(".fa-sort-amount-desc")

      # sort asc & namespace.name
      visit repositories_path(sort_asc: true, sort_by: "namespace.name")

      expect(page).to have_css("th:nth-child(2) .fa-sort-amount-asc")

      # sort desc & namespace.name
      visit repositories_path(sort_asc: false, sort_by: "namespace.name")

      expect(page).to have_css("th:nth-child(2) .fa-sort-amount-desc")
    end

    it "URL is updated when repositories column is sorted" do
      visit repositories_path

      expect(page).to have_css(".repositories-panel:last-of-type th:nth-child(2)")

      # sort asc & namespace.name
      find(".repositories-panel:last-of-type th:nth-child(2)").click

      expect(page).to have_css(".repositories-panel th:nth-child(2) .fa-sort-amount-asc")
      path = repositories_path(sort_asc: true, sort_by: "namespace.name")
      expect(page).to have_current_path(path)

      # sort desc & namespace.name
      find(".repositories-panel:last-of-type th:nth-child(2)").click

      expect(page).to have_css(".repositories-panel th:nth-child(2) .fa-sort-amount-desc")
      path = repositories_path(sort_asc: false, sort_by: "namespace.name")
      expect(page).to have_current_path(path)
    end

    it "Repositories table pagination is reachable through url" do
      # page 2
      visit repositories_path(page: 2)

      expect(page).to have_css(".repositories-panel .pagination li.active:nth-child(3)")

      # page 1
      visit repositories_path(page: 1)

      expect(page).to have_css(".repositories-panel .pagination li.active:nth-child(2)")
    end

    it "URL is updated when page is changed" do
      visit repositories_path

      expect(page).to have_css(".repositories-panel:last-of-type .pagination li:nth-child(3)")

      # page 2
      find(".repositories-panel:last-of-type .pagination li:nth-child(3) a").click

      selector = ".repositories-panel:last-of-type .pagination li.active:nth-child(3)"
      expect(page).to have_css(selector)
      expect(page).to have_current_path(repositories_path(page: 2))

      # page 1
      find(".repositories-panel:last-of-type .pagination li:nth-child(2) a").click

      selector = ".repositories-panel:last-of-type .pagination li.active:nth-child(2)"
      expect(page).to have_css(selector)
      expect(page).to have_current_path(repositories_path(page: 1))
    end
  end

  describe "repository#show" do
    it "Visual aid for each role is shown properly" do
      visit repository_path(repository)
      info = page.find(".repository-information-icon")["data-content"]
      expect(info).to have_content("You can push images")
      expect(info).to have_content("You can pull images")
      expect(info).to have_content("You are an owner of this repository")
      expect(info).not_to have_content("You are a contributor in this repository")
      expect(info).not_to have_content("You are a viewer in this repository")

      login_as user2, scope: :user
      visit repository_path(repository)
      info = page.find(".repository-information-icon")["data-content"]
      expect(info).to have_content("You can push images")
      expect(info).to have_content("You can pull images")
      expect(info).to have_content("You are a contributor in this repository")
      expect(info).not_to have_content("You are an owner of this repository")
      expect(info).not_to have_content("You are a viewer in this repository")

      login_as user3, scope: :user
      visit repository_path(repository)
      info = page.find(".repository-information-icon")["data-content"]
      expect(info).to have_content("You can pull images")
      expect(info).to have_content("You are a viewer in this repository")
      expect(info).not_to have_content("You can push images")
      expect(info).not_to have_content("You are an owner of this repository")
      expect(info).not_to have_content("You are a contributor in this repository")
    end

    context "when user_permission.push_images is disabled" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["enabled"] = false
      end

      it "Visual aid for each role is shown properly" do
        login_as user
        visit repository_path(repository)
        info = page.find(".repository-information-icon")["data-content"]
        expect(info).to have_content("You can push images")
        expect(info).to have_content("You can pull images")
        expect(info).to have_content("You are an owner of this repository")
        expect(info).not_to have_content("You are a contributor in this repository")
        expect(info).not_to have_content("You are a viewer in this repository")

        login_as user2
        visit repository_path(repository)
        info = page.find(".repository-information-icon")["data-content"]
        expect(info).not_to have_content("You can push images")
        expect(info).to have_content("You can pull images")
        expect(info).not_to have_content("You are an owner of this repository")
        expect(info).to have_content("You are a contributor in this repository")
        expect(info).not_to have_content("You are a viewer in this repository")
      end
    end

    it "A user can star a repository", js: true do
      visit repository_path(repository)
      expect(page).to have_css("#toggle_star")
      find("#toggle_star").click
      wait_for_ajax
      expect(page).to have_current_path(repository_path(repository))

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("1")
      expect(repo.stars.count).to be 1
    end

    it "A user can unstar a repository", js: true do
      visit repository_path(starred_repo)
      expect(page).to have_css("#toggle_star")
      find("#toggle_star").click
      wait_for_ajax
      expect(page).to have_current_path(repository_path(starred_repo))

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("0")
      expect(repo.stars.count).to be 0
    end

    it "Groupped tags are handled properly" do
      ["", "", "same", "same", "another", "yet-another"].each_with_index do |digest, idx|
        create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
               image_id: "Image", created_at: idx.hours.ago)
      end

      expectations = [["tag0"], ["tag1"], %w[tag2 tag3], ["tag4"], ["tag5"]]

      visit repository_path(repository)

      page.all(".tags tr").each_with_index do |row, idx|
        expect(row.text).to include("Image")

        # Skip the header.
        next if idx == 0

        expectations[idx - 1].each { |tag| expect(row.text).to include(tag) }
      end
    end

    it "works if both the digest and the image_id are blank" do
      create(:tag, author: user, repository: repository, digest: nil, image_id: nil)
      create(:tag, author: user, repository: repository, digest: "nonblank", image_id: nil)

      visit repository_path(repository)
    end

    context "delete and security enabled" do
      before do
        APP_CONFIG["delete"] = { "enabled" => true }

        enable_security_vulns_module!
      end

      it "The delete feature is available only for allowed users" do
        visit repository_path(repository)
        expect(page).to have_content("Delete repository")

        login_as user2, scope: :user
        visit repository_path(repository)
        expect(page).not_to have_content("Delete repository")
      end

      it "A user can delete a repository", js: true do
        visit repository_path(repository)

        repository_count = Repository.count
        find(".repository-delete-btn").click
        find(".repository-confirm-btn").click
        expect(Repository.count).to be(repository_count - 1)
        expect(page).to have_content("Repository removed with all its tags")
      end

      it "A user deletes a tag", js: true do
        %w[lorem ipsum].each_with_index do |digest, idx|
          create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
          image_id: "Image", created_at: idx.hours.ago, updated_at: idx.hours.ago)
        end

        VCR.use_cassette("registry/get_image_manifest_tags", record: :none) do
          visit repository_path(repository)

          expect(page).not_to have_content("Delete tag")
          find_tag_checkbox("tag0").click
          expect(page).to have_content("Delete tag")

          find(".tag-delete-btn").click
          expect(page).to have_content("tag0 successfully removed")
        end
      end

      it "A user deletes tags", js: true do
        %w[lorem ipsum ipsum].each_with_index do |digest, idx|
          create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
          image_id: "Image", created_at: idx.hours.ago, updated_at: idx.hours.ago)
        end

        VCR.use_cassette("registry/get_image_manifest_tags", record: :none) do
          visit repository_path(repository)

          expect(page).not_to have_content("Delete tags")
          find_tag_checkbox("tag1").click
          expect(page).to have_content("Delete tags")
          find(".tag-delete-btn").click
          expect(page).to have_content("tag1, tag2 successfully removed")
        end
      end

      it "A user deletes a repository by deleting all tags", js: true do
        %w[lorem ipsum].each_with_index do |digest, idx|
          create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
          image_id: "Image", created_at: idx.hours.ago)
        end

        VCR.use_cassette("registry/get_image_manifest_tags", record: :none) do
          visit repository_path(repository)

          expect(page).not_to have_content("Delete tags")
          find("tbody tr input[type='checkbox']", match: :first)
          all("tbody tr input[type='checkbox']").each(&:click)
          expect(page).to have_content("Delete tags")
          find(".tag-delete-btn").click
          expect(page).to have_content("Repository removed with all its tags")
        end
      end
    end
  end
end
