require "rails_helper"

feature "Search support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:repo) { create(:repository, namespace: user.teams.first.namespaces.first) }

  before do
    login user
    visit root_path
  end

  scenario "It allows the logged in user to search for repositories", js: true do
    # Firstly only the button is visible. Let's click it!
    expect(find("#search", visible: false)).to_not be_visible
    find("header .header-open-search").click
    wait_for_effect_on("header .header-open-search")

    # After the effect, the search element should be visible and focused,
    # and the main button hidden.
    expect(find("#search")).to be_visible
    expect(focused_element_id).to eq "search"
    expect(find("header .header-open-search", visible: false)).to_not be_visible

    # The submit button is disabled, until the user writes something and
    # clicks. Note that the last click has to be done with 'trigger', because
    # otherwise Poltergeist complains on overlapping elements.
    expect(disabled?("header .header-search-form .btn")).to be true
    fill_in "Search", with: repo.name
    wait_for_effect_on("header .header-search-form .btn")
    expect(disabled?("header .header-search-form .btn")).to be false
    find("header .header-search-form .btn").trigger("click")

    # Now we are on the search page. Note that because of the previous
    # 'trigger' call, Capybara gets a bit lost and we have to wait for our
    # expectation manually...
    wait_until { current_path == search_index_path }
    expect(current_path).to eq search_index_path

    # Check that the contents are what we are expecting.
    expect(page).to have_content(user.username)
  end

  scenario "The search elements is hidden back when it loses focus", js: true do
    # Make the search element appear.
    expect(find("#search", visible: false)).to_not be_visible
    find("header .header-open-search").click
    wait_for_effect_on("#search")
    expect(focused_element_id).to eq "search"

    # Now it loses focus.
    find("aside").click
    wait_for_effect_on("#search")
    expect(focused_element_id).to_not eq "search"
    expect(find("#search", visible: false)).to_not be_visible
  end
end
