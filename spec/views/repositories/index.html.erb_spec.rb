require 'rails_helper'

RSpec.describe "repositories/index", type: :view do
  before(:each) do
    assign(:repositories, [
      Repository.create!(
        :name => "Name"
      ),
      Repository.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of repositories" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
