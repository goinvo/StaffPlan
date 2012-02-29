require 'spec_helper'

describe ApplicationController do
  
  controller do
    def index
      render :text => "I'm the application_controller"
    end
  end
  
  describe 'Authentication' do
    context "with no logged in user" do
      it "should redirect to root_url if a user can't be found" do
        session[:user_id].should be_nil
        get :index
        response.should redirect_to(new_session_url)
      end
      
      it "should look up a User by session[:user_id] if present" do
        session[:user_id] = bogus_user_id = 'bogus'
        User.expects(:find).with(bogus_user_id).returns(nil).twice
        get :index
        response.should redirect_to(new_session_url)
      end
    end
    
    context "with a logged in user" do
      before(:each) do
        @user = login_user
      end
      
      it "should let the user pass" do
        session[:user_id].should eq(@user.id)
        get :index
        response.should be_success
      end
    end
  end
  
  describe 'Full/Mobile switching' do
    before(:each) do
      @user = login_user
    end
    
    it "should not change the session[:mobile_view] if the param isn't present" do
      mobile_view = session[:mobile_view]
      get :index
      session[:mobile_view].should eq(mobile_view)
    end
    
    it "should set session[:mobile_view] to 'true' if the :mobile_view parameter is 'true'" do
      session[:mobile_view] = false
      get :index, mobile_view: "true"
      session[:mobile_view].should eq(true)
    end
    
    it "should set session[:mobile_view] to 'false' if the :mobile_view parameter is 'false'" do
      session[:mobile_view] = true
      get :index, mobile_view: "false"
      session[:mobile_view].should eq(false)
    end
  end
end
