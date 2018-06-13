# frozen_string_literal: true

require "rails_helper"

describe "Repositories comments support" do
  let!(:registry) { create(:registry, hostname: "registry.test.lan") }
  let!(:admin) { create(:admin) }
  let!(:owner) { create(:user) }
  let!(:user) { create(:user) }
  let!(:team) { create(:team, owners: [owner]) }
  let!(:public_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_public],
           team:       team)
  end
  let!(:visible_repository) { create(:repository, namespace: public_namespace) }
  let!(:protected_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_protected],
           team:       team)
  end
  let!(:protected_repository) { create(:repository, namespace: protected_namespace) }
  let!(:private_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_private],
           team:       team)
  end
  let!(:invisible_repository) { create(:repository, namespace: private_namespace) }
  let(:comment) { create(:comment, author: owner) }
  let!(:commented_repository) do
    create(:repository, comments: [comment], namespace: public_namespace)
  end

  before do
    login_as user, scope: :user
  end

  describe "comment#create", js: true do
    it "An user comments on a repository under a public namespace" do
      visit repository_path(visible_repository)

      expect(page).to have_content("Nobody has left a comment")

      find(".toggle-link-new-comment").click

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    it "An user comments on a repository under a protected namespace" do
      visit repository_path(protected_repository)

      expect(page).to have_content("Nobody has left a comment")

      find(".toggle-link-new-comment").click
      expect(page).to have_button("Add")

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    it "An admin comments on any repository" do
      login_as admin, scope: :user
      visit repository_path(invisible_repository)

      expect(page).to have_content("Nobody has left a comment")

      find(".toggle-link-new-comment").click
      expect(page).to have_button("Add")

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    it "An user cannot comment on a repository without access" do
      visit repository_path(invisible_repository)

      expect(page).to have_content("You are not authorized to access this page")
    end

    it "An user cannot comment an empty text" do
      visit repository_path(visible_repository)

      find(".toggle-link-new-comment").click

      fill_in "comment[body]", with: ""

      expect(page).to have_content("Comment can't be blank")
    end
  end

  describe "comment#delete", js: true do
    it "An user deletes his own comment" do
      login_as owner, scope: :user
      visit repository_path(commented_repository)

      find("#comment_#{comment.id}").hover
      expect(page).to have_content("Delete comment")

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id} .delete-comment-btn").click
      find(".popover-content .yes").click
      wait_for_ajax

      expect(page).not_to have_content(comment.body)
    end

    it "An user cannot delete other users' comment" do
      visit repository_path(commented_repository)

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id}").hover
      expect(page).not_to have_content("Delete comment")
    end

    it "An admin deletes any comment" do
      login_as admin, scope: :user
      visit repository_path(commented_repository)

      find("#comment_#{comment.id}").hover
      expect(page).to have_content("Delete comment")

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id} .delete-comment-btn").click
      find(".popover-content .yes").click
      wait_for_ajax

      expect(page).not_to have_content(comment.body)
    end
  end
end
