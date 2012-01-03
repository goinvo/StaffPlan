require 'spec_helper'

describe "users/show.html.haml" do
  before(:each) do
    @user = assign(:user, Factory(:user))
  end

  it "renders attributes in <p>" do
    render
  end
end
