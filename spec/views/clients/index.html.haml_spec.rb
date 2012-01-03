require 'spec_helper'

describe "clients/index.html.haml" do
  before(:each) do
    assign(:clients, [
      Factory(:client),
      Factory(:client)
    ])
  end

  it "renders a list of clients" do
    render
  end
end
