require 'rails_helper'

RSpec.describe "images/show", type: :view do
  before(:each) do
    @image = assign(:image, Image.create!(
      :name => "Name",
      :repository_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
