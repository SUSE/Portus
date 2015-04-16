require 'rails_helper'

RSpec.describe "repositories/show", type: :view do
  before(:each) do
    @repository = assign(:repository, Repository.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
