require 'spec_helper'

describe "users/new.html.haml" do
  before(:each) do
    assign(:user, Factory.build(:user))
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path, :method => "post" do
    end
  end
end
