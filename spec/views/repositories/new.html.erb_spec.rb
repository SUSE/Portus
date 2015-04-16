require 'rails_helper'

RSpec.describe "repositories/new", type: :view do
  before(:each) do
    assign(:repository, Repository.new(
      :name => "MyString"
    ))
  end

  it "renders new repository form" do
    render

    assert_select "form[action=?][method=?]", repositories_path, "post" do

      assert_select "input#repository_name[name=?]", "repository[name]"
    end
  end
end
