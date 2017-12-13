# frozen_string_literal: true

require "rails_helper"

describe "help/index" do
  it "renders the page successfully" do
    render
    expect(assert_select("h5").text).to eq "Help"
  end
end
