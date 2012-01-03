require 'spec_helper'

describe "clients/edit.html.haml" do
  before(:each) do
    @client = assign(:client, Factory(:client))
  end

  it "renders the edit client form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => clients_path(@client), :method => "post" do
    end
  end
end
