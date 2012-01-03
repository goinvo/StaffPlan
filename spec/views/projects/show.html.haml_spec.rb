require 'spec_helper'

describe "projects/show.html.haml" do
  before(:each) do
    @project = assign(:project, Factory(:project))
  end

  it "renders attributes in <p>" do
    render
  end
end
