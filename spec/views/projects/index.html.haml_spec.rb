require 'spec_helper'

describe "projects/index.html.haml" do
  before(:each) do
    assign(:projects, [
      Factory(:project),
      Factory(:project)
    ])
  end

  it "renders a list of projects" do
    render
  end
end
