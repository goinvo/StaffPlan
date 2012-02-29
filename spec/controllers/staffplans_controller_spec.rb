require 'spec_helper'

describe StaffplansController do
  before(:each) do
    @current_user = login_user
    @company = Factory(:company)
    @current_user.update_attributes(current_company_id: @company.id)
  end
  
  describe 'GET#show' do
    it "should redirect to root_url if a user can't be found" do
      get :show, :id => "bogus"
      response.should be_redirect
      response.should redirect_to(root_url)
    end
    
    it "should find the targeted user and populate some instance variables when the ID is valid" do
      target_user = user_with_clients_and_projects
      @company.users << target_user
      get :show, :id => target_user.id
      response.should be_success
      response.should render_template("staffplans/show")
      assigns[:target_user].should == target_user
      assigns[:clients].should_not be_nil
    end
  end
end
