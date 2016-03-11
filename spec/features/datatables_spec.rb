require "rails_helper"

feature "Datatables support" do
  let!(:registry) { create(:registry, hostname: "registry1.test.lan") }
  let!(:registry2) { create(:registry, hostname: "registry2.test.lan") }
  let!(:registry3) { create(:registry, hostname: "registry3.test.lan") }
  let!(:user1) { create(:admin, username: "admin") }
  let!(:user2) { create(:user, username: "malcom") }
  let!(:user3) { create(:user, username: "zdmin") }
  let!(:team1) { create(:team, name: "1test", owners: [user1, user2, user3]) }
  let!(:team2) { create(:team, name: "2test", owners: [user1]) }
  let!(:team3) { create(:team, name: "3test", owners: [user1]) }
  let!(:namespace1) { create(:namespace, name: "1test", team: team1, registry: registry) }
  let!(:namespace2) { create(:namespace, name: "2test", team: team1, registry: registry) }
  let!(:namespace3) { create(:namespace, name: "3test", team: team1, registry: registry) }
  let!(:repository1) { create(:repository, name: "1test", namespace: namespace1) }
  let!(:repository2) { create(:repository, name: "2test", namespace: namespace1) }
  let!(:repository3) { create(:repository, name: "3test", namespace: namespace1) }
  let!(:tag1) { create(:tag, name: "tag1", repository: repository1) }
  let!(:tag2) { create(:tag, name: "tag2", repository: repository1) }
  let!(:tag3) { create(:tag, name: "tag3", repository: repository1) }

  let(:tables) do
    { "teams"        => { "id"         => "#teams-table",
                          "symbol"     => :team,
                          "columns"    => ["Team",
                                           "Role",
                                           "Number of members",
                                           "Number of namespaces"],
                          "pagination" => true },
      "admin_teams"  => { "id"         => "#admin-teams-table",
                          "symbol"     => :team,
                          "columns"    => ["Team",
                                           "Role",
                                           "Number of members",
                                           "Number of namespaces"],
                          "pagination" => true },
      "namespaces"   => { "id"         => "#namespaces-table",
                          "symbol"     => :namespace,
                          "columns"    => ["Name", "Repositories", "Created At"],
                          "pagination" => true },
      "snamespaces"  => { "id"         => "#snamespaces-table",
                          "symbol"     => :namespace,
                          "columns"    => ["Name", "Repositories", "Created At"],
                          "pagination" => false },
      "registries"   => { "id"         => "#registries-table",
                          "symbol"     => :registry,
                          "columns"    => ["Hostname"],
                          "pagination" => false },
      "users"        => { "id"         => "#admin-users-table",
                          "symbol"     => :user,
                          "columns"    => ["Name", "Email", "Namespaces", "Teams"],
                          "pagination" => true },
      "repositories" => { "id"         => "#repositories-table",
                          "symbol"     => :repository,
                          "columns"    => ["Repository", "# Tags"],
                          "pagination" => true },
      "members"      => { "id"         => "#members-table",
                          "symbol"     => :user,
                          "columns"    => ["User", "Role"],
                          "pagination" => true },
      "tags"         => { "id"         => "#tags-table",
                          "symbol"     => :tag,
                          "columns"    => ["Pushed At"],
                          "pagination" => "false" } }
  end
  let(:sites) do
    [
      { "path"             => teams_path,
        "tables"           => [tables["teams"]],
        "number_of_tables" => 1 },
      { "path"             => admin_teams_path,
        "tables"           => [tables["admin_teams"]],
        "number_of_tables" => 1 },
      { "path"             => namespaces_path,
        "tables"           => [tables["namespaces"], tables["snamespaces"]],
        "number_of_tables" => 2 },
      { "path"             => admin_namespaces_path,
        "tables"           => [tables["namespaces"], tables["snamespaces"]],
        "number_of_tables" => 2 },
      { "path"             => admin_registries_path,
        "tables"           => [tables["registries"]],
        "number_of_tables" => 1 },
      { "path"             => admin_users_path,
        "tables"           => [tables["users"]],
        "number_of_tables" => 1 },
      { "path"             => namespace_path(namespace1.id),
        "tables"           => [tables["repositories"]],
        "number_of_tables" => 1 },
      { "path"             => team_path(team1.id),
        "tables"           => [tables["members"], tables["namespaces"]],
        "number_of_tables" => 2 }
    ]
  end

  before do
    login_as user1, scope: :user
  end

  describe "Datatables#Active" do
    scenario "Check every table and click on all sortable columns", js: true do
      sites.each do |site|
        site["tables"].each do |t|
          visit site["path"]
          expect(page).to have_css("table.dataTable", count: site["number_of_tables"])
          table = find(t["id"])
          table.all("th").each do |th|
            if t["columns"].include? th.text
              th.click
              expect(table).to have_css("th.sorting_asc", text: th.text)
              th.click
              expect(table).to have_css("th.sorting_desc", text: th.text)
            else
              expect(table).to have_css("th.sorting_disabled")
            end
          end
        end
      end
    end
  end

  describe "Datatables#Sorting" do
    scenario "Click on the first sortable column twice and check the first row matches", js: true do
      sites.each do |site|
        site["tables"].each do |t|
          visit site["path"]
          table = find(t["id"])
          column = table.first("th.sorting")
          xpath_str = ".//tr/th[@class='sorting'][1]/preceding-sibling::th"
          position_of_column = table.all(:xpath, xpath_str).size + 1
          column.click
          expect(table).to have_css("th.sorting_asc", text: column.text)
          first_row_entry = table.first(:xpath, ".//tr/td[#{position_of_column}]")
          expect(first_row_entry.text).to match(/1test|admin|registry1\.test\.lan/)
          column.click
          first_row_entry = table.first(:xpath, ".//tr/td[#{position_of_column}]")
          expect(table).to have_css("th.sorting_desc", text: column.text)
          expect(first_row_entry.text).to match(/3test|zdmin|registry3\.test\.lan/)
        end
      end
    end
  end

  describe "Datatables#Paging" do
    # pageLength = 10
    scenario "Create 11 new entries and check if the panel-footer is visible", js: true do
      sites.each do |site|
        site["tables"].each do |t|
          next unless t["pagination"]
          visit site["path"]
          table = find(t["id"])
          panel = table.find(:xpath, "../../../..")
          footer = panel.find(".panel-footer")
          create_records(7, t["symbol"])
          expect(footer).to have_selector("div", visible: false)
          create_records(1, t["symbol"])
          visit site["path"]
          footer = panel.find(".panel-footer")
          expect(footer).to have_selector("div", visible: true)
        end
      end
    end
  end
end
