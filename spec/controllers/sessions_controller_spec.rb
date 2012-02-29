require 'spec_helper'

describe SessionsController do
  
  describe "GET#new" do
    it "should render the login form" do
      get :new
      response.should be_success
      response.should render_template("sessions/new")
    end
  end

  describe "POST#create" do
    it "should log the user in if the credentials are valid" do
      user = Factory(:user)
      post :create, email: user.email, password: user.password
      response.should be_redirect
      response.should redirect_to(root_url)
    end
    
    it "should re-render the login form if the user can't be found" do
      post :create, :email => "thiswont@befound.com"
      response.should redirect_to new_session_url
      session[:user_id].should be_nil
    end
    
    it "should re-render the login form if the credentials are invalid" do
      post :create
      response.should redirect_to new_session_url
      session[:user_id].should be_nil
    end
  end

  describe "GET#destroy" do
    it "should set session[:user_id] to nil" do
      @current_user = Factory(:user)
      login_user(@current_user)
      
      get :destroy
      session[:user_id].should be_nil
      response.should be_redirect
      response.should redirect_to(root_url)
    end
  end

end
