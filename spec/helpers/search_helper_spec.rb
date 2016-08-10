require "rails_helper"

RSpec.describe SearchHelper, type: :helper do

  describe "build_search_category_url" do
    it "returns true if current user is an owner of the team" do
      expected = "#{search_index_path}?utf8=✓&search=&type=repositories"
      params = { utf8: "✓", search: "" }
      expect(helper.build_search_category_url(params, "repositories")).to eq expected
    end
  end

  describe "dynamic_filter_input" do
    it "renders dynamic filter input form" do
      expected = '<form id="filter_form" class="input-group shared-search filter-wrapper" '\
                 'action="/namespaces" accept-charset="UTF-8" method="get">'\
                 '<input name="utf8" type="hidden" value="&#x2713;" />'\
                 '<i class="fa fa-filter"></i><input type="text" name="filter" '\
                 'id="filter_input" class="form-control filter-input" placeholder="Filter" />' \
                 "</form>"
      expect(helper.dynamic_filter_input("/namespaces")).to eq expected
    end
  end
end
