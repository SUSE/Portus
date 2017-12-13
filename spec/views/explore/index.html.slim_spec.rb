# frozen_string_literal: true

require "rails_helper"

describe "explore/index", type: :view do
  it "renders the page successfully" do
    @repositories = []
    render
    assert_select("#explore_search")
  end
end
