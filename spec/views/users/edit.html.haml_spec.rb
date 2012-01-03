require 'spec_helper'

describe "users/edit.html.haml" do
  before(:each) do
    @user = assign(:user, Factory(:user))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path(@user), :method => "post" do
    end
  end
end
