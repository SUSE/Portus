# frozen_string_literal: true

require "rails_helper"

def find_tag_checkbox(name)
  tag = find("div", text: /\A#{name}\z/)
  tag.find(:xpath, "../..").find(".pretty-checkbox")
end

describe "Feature: Repositories", js: true do
  let!(:registry) { create(:registry, hostname: "registry.test.lan") }
  let!(:user) { create(:admin) }
  let!(:contributor) { create(:user, username: "contributor") }
  let!(:viewer) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [contributor], viewers: [viewer]) }
  let!(:team2) { create(:team, owners: [contributor], viewers: [viewer]) }
  let!(:namespace) { create(:namespace, team: team, name: "team1") }
  let!(:namespace2) { create(:namespace, team: team2, name: "team2") }
  let!(:repository) { create(:repository, namespace: namespace, name: "busybox") }
  let!(:repository_with_description) do
    create(:repository, namespace: namespace, name: "box_desc", description: "description here")
  end
  let!(:repository2) { create(:repository, namespace: namespace2, name: "busybox2") }
  let!(:starred_repo) { create(:repository, namespace: namespace) }
  let!(:star) { create(:star, user: user, repository: starred_repo) }

  before do
    login_as user, scope: :user
  end

  describe "repository#index" do
    before do
      create_list(:repository, 15, namespace: namespace)
      visit repositories_path
    end

    context "table sorting" do
      it "considers url parameters" do
        # sort asc & updated_at
        visit repositories_path(sort_asc: true, sort_by: "updated_at")
        expect(page).to have_css("th:nth-child(4) .fa-sort-amount-asc")

        # sort desc & updated_at
        visit repositories_path(sort_asc: false, sort_by: "updated_at")
        expect(page).to have_css("th:nth-child(4) .fa-sort-amount-desc")
      end

      it "updates url when sorted" do
        path = repositories_path(sort_asc: true, sort_by: "updated_at")
        find(".repositories-panel:first-of-type th:nth-child(4)").click

        expect(page).to have_css(".repositories-panel th:nth-child(4) .fa-sort-amount-asc")
        expect(page).to have_current_path(path)

        # sort desc & updated_at
        path = repositories_path(sort_asc: false, sort_by: "updated_at")
        find(".repositories-panel:first-of-type th:nth-child(4)").click

        expect(page).to have_css(".repositories-panel th:nth-child(4) .fa-sort-amount-desc")
        expect(page).to have_current_path(path)
      end
    end

    context "table pagination" do
      it "considers url parameters" do
        # page 2
        visit repositories_path(page: 2)
        expect(page).to have_css(".repositories-panel .pagination li.active:nth-child(3)")

        # page 1
        visit repositories_path(page: 1)
        expect(page).to have_css(".repositories-panel .pagination li.active:nth-child(2)")
      end

      it "updates url when paginated" do
        within ".repositories-panel:first-of-type" do
          # page 2
          find(" .pagination li:nth-child(3) a").click

          expect(page).to have_css(".pagination li.active:nth-child(3)")
          expect(page).to have_current_path(repositories_path(page: 2))

          # page 1
          find(".pagination li:nth-child(2) a").click

          expect(page).to have_css(".pagination li.active:nth-child(2)")
          expect(page).to have_current_path(repositories_path(page: 1))
        end
      end
    end

    context "when admin" do
      it "shows all repositories" do
        expect(page).to have_content(repository.name)
        expect(page).to have_content("Other repositories")
      end
    end
  end

  describe "repository#show" do
    it "Visual aid for each role is shown properly" do
      visit repository_path(repository)
      click_link "Overview"
      expect(page).to have_content("You can push images")
      expect(page).to have_content("You can pull images")
      expect(page).to have_content("You are an owner of this repository")
      expect(page).not_to have_content("You are a contributor in this repository")
      expect(page).not_to have_content("You are a viewer in this repository")

      login_as contributor, scope: :user
      visit repository_path(repository)
      click_link "Overview"
      expect(page).to have_content("You can push images")
      expect(page).to have_content("You can pull images")
      expect(page).to have_content("You are a contributor in this repository")
      expect(page).not_to have_content("You are an owner of this repository")
      expect(page).not_to have_content("You are a viewer in this repository")

      login_as viewer, scope: :user
      visit repository_path(repository)
      click_link "Overview"
      expect(page).to have_content("You can pull images")
      expect(page).to have_content("You are a viewer in this repository")
      expect(page).not_to have_content("You can push images")
      expect(page).not_to have_content("You are an owner of this repository")
      expect(page).not_to have_content("You are a contributor in this repository")
    end

    context "overview description" do
      before do
        visit repository_path(repository)
        click_link "Overview"
      end

      it "shows 'click to set description'" do
        expect(page).to have_content("Click to set repository description")
      end

      it "shows 'edit description' button" do
        visit repository_path(repository_with_description)
        click_link "Overview"

        expect(page).to have_content("Edit description")
      end

      it "updates a repository description" do
        find(".click-description").click
        description = "New description"
        fill_in "repository[description]", with: description
        click_button "Save"

        expect(page).to have_content("Repository's description was updated successfully")
        expect(page).to have_content(description)
      end
    end

    context "when user_permission.push_images is disabled" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
      end

      it "Visual aid for each role is shown properly" do
        login_as user
        visit repository_path(repository)
        click_link "Overview"
        expect(page).to have_content("You can push images")
        expect(page).to have_content("You can pull images")
        expect(page).to have_content("You are an owner of this repository")
        expect(page).not_to have_content("You are a contributor in this repository")
        expect(page).not_to have_content("You are a viewer in this repository")

        login_as contributor, scope: :user
        visit repository_path(repository)
        click_link "Overview"
        expect(page).not_to have_content("You can push images")
        expect(page).to have_content("You can pull images")
        expect(page).not_to have_content("You are an owner of this repository")
        expect(page).to have_content("You are a contributor in this repository")
        expect(page).not_to have_content("You are a viewer in this repository")
      end
    end

    context "vulnerabilities" do
      let!(:tag) do
        create(:tag, name: "tag0", repository: repository, scanned: Tag.statuses[:scan_done])
      end
      let!(:vulnerability)  { create(:vulnerability, name: "CVE-1234", scanner: "clair") }
      let!(:vulnerability1) { create(:vulnerability, name: "CVE-5678", scanner: "dummy") }
      let!(:scan_result)    { create(:scan_result, tag: tag, vulnerability: vulnerability) }
      let!(:scan_result1)   { create(:scan_result, tag: tag, vulnerability: vulnerability1) }

      before do
        APP_CONFIG["security"]["dummy"]["server"] = "yeah"
      end

      it "reports vulnerabilities" do
        visit repository_path(repository)
        expect(page).to have_content("2 High - 2 total")
      end
    end

    it "A user can star a repository" do
      visit repository_path(repository)
      expect(page).to have_css("#toggle_star")
      find("#toggle_star").click
      expect(page).to have_current_path(repository_path(repository))

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("1")
      expect(repo.stars.count).to be 1
    end

    it "A user can unstar a repository" do
      visit repository_path(starred_repo)
      expect(page).to have_css("#toggle_star")
      find("#toggle_star").click
      expect(page).to have_current_path(repository_path(starred_repo))

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("0")
      expect(repo.stars.count).to be 0
    end

    it "Groupped tags are handled properly" do
      ["", "", "same", "same", "another", "yet-another"].each_with_index do |digest, idx|
        create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
               image_id: "Image", created_at: idx.hours.ago, updated_at: idx.hours.ago)
      end

      expectations = [%w[tag0 tag1], %w[tag2 tag3], ["tag4"], ["tag5"]]

      visit repository_path(repository)

      page.all(".tags tr").each_with_index do |row, idx|
        expect(row.text).to include("Image")

        # Skip the header.
        next if idx == 0

        expectations[idx - 1].each do |tag|
          expect(row.text).to include(tag)
        end
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

        login_as contributor, scope: :user
        visit repository_path(repository)
        expect(page).not_to have_content("Delete repository")
      end

      it "A user can delete a repository" do
        visit repository_path(repository)

        click_confirm_popover(".repository-delete-btn")
        expect(page).to have_content("Repository removed with all its tags")
      end

      it "A user deletes a tag" do
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

      it "A user deletes tags" do
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

      # TODO: this is consistently failing since ruby 2.6.x. Before it was only
      # flaky on Travis CI.
      if ENV["ALL"].present?
        it "A user deletes a repository by deleting all tags" do
          %w[lorem ipsum].each_with_index do |digest, idx|
            create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest,
                   image_id: "Image", created_at: idx.hours.ago)
          end

          VCR.use_cassette("registry/get_image_manifest_tags", record: :none) do
            visit repository_path(repository)

            expect(page).not_to have_content("Delete tags")
            find("tbody tr .pretty-checkbox", match: :first)
            all("tbody tr .pretty-checkbox").each(&:click)
            expect(page).to have_content("Delete tags")
            find(".tag-delete-btn").click
            expect(page).to have_content("Repository removed with all its tags")
          end
        end
      end
    end
  end
end
