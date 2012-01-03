require 'spec_helper'

describe "clients/new.html.haml" do
  before(:each) do
    assign(:client, Factory.build(:client))
  end

  it "renders new client form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => clients_path, :method => "post" do
    end
  end
end
