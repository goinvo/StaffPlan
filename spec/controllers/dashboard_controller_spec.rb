require 'spec_helper'

describe DashboardController do
  
  before(:each) do
    @current_user = Factory(:user)
    login_user(@current_user)
  end
  
  describe "GET#show" do
    it "returns http success" do
      get :show
      response.should be_success
    end
  end

end
