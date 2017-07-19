require "rails_helper"

feature "Repositories comments support" do
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

  describe "comment#create" do
    scenario "An user comments on a repository under a public namespace", js: true do
      visit repository_path(visible_repository)

      expect(page).to have_content("Nobody has left a comment")

      find("#write_comment_repository_btn").click
      wait_for_effect_on("#write_comment_form")

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    scenario "An user comments on a repository under a protected namespace", js: true do
      visit repository_path(protected_repository)

      expect(page).to have_content("Nobody has left a comment")

      find("#write_comment_repository_btn").click
      wait_for_effect_on("#write_comment_form")

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    scenario "An admin comments on any repository", js: true do
      login_as admin, scope: :user
      visit repository_path(invisible_repository)

      expect(page).to have_content("Nobody has left a comment")

      find("#write_comment_repository_btn").click
      wait_for_effect_on("#write_comment_form")

      fill_in "comment[body]", with: "Something"
      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Something")
      expect(page).not_to have_content("Nobody has left a comment")
    end

    scenario "An user cannot comment on a repository without access", js: true do
      visit repository_path(invisible_repository)

      expect(page).to have_content("You are not authorized to access this page")
    end

    scenario "An user cannot comment an empty text", js: true do
      visit repository_path(visible_repository)

      find("#write_comment_repository_btn").click
      wait_for_effect_on("#write_comment_form")

      click_button "Add"
      wait_for_ajax

      expect(page).to have_content("Body can't be blank")
      expect(page).to have_content("Nobody has left a comment")
    end
  end

  describe "comment#delete" do
    scenario "An user deletes his own comment", js: true do
      login_as owner, scope: :user
      visit repository_path(commented_repository)

      find("#comment_#{comment.id}").hover
      expect(page).to have_content("Delete comment")

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id} .destroy_comments_btn").click
      click_link "Yes"
      expect(page).not_to have_content(comment.body)
    end

    scenario "An user cannot delete other users' comment", js: true do
      visit repository_path(commented_repository)

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id}").hover
      expect(page).not_to have_content("Delete comment")
    end

    scenario "An admin deletes any comment", js: true do
      login_as admin, scope: :user
      visit repository_path(commented_repository)

      find("#comment_#{comment.id}").hover
      expect(page).to have_content("Delete comment")

      expect(page).to have_content(comment.body)
      find("#comment_#{comment.id} .destroy_comments_btn").click
      click_link "Yes"
      expect(page).not_to have_content(comment.body)
    end
  end
end
