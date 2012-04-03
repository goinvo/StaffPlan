require 'spec_helper'

describe PasswordResetsController do

  before(:each) do
    @user = Factory(:user)
  end

  describe "PasswordResetsController#new (GET)" do
    it "should allow users that are not logged in to access the password reset page" do
      get :new
      response.should_not be_redirect
    end
  end 

  describe "PasswordResetsController#update (PUT)" do
    before(:each) do
      @parameters = {}
      @parameters.store(:user, {
        password: "mysecretpassword", 
        password_confirmation: "mysecretpassword"
      })
    end 
    context "A user is found in the DB with the given token" do
      before(:each) do
        User.stubs(:with_registration_token).with(anything).returns(@user)
      end
      context "The password and password confirmation are valid and match" do
        before(:each) do
          User.any_instance.expects(:save).times(2).returns(true)
        end
        it "should reset the users' registration token to nil" do
          put :update, @parameters 
          assigns[:user].registration_token.should be_nil
        end
        it "should log @user in" do
          put :update, @parameters
          session[:user_id].should eq(@user.id) 
        end
        it "should display a success notification to the user" do
          put :update, @parameters 
          flash[:notice].should_not be_empty
        end
        it "should redirect the user to his/her staffplan page" do
          put :update, @parameters 
          response.should redirect_to(staffplan_path(@user))
        end
      end
      context "The password and password are either invalid or don't match" do
        it "should render the edit form again" do
          User.any_instance.expects(:save).returns(false)
          put :update, @parameters 
          response.should render_template(:edit)
        end
      end
    end

    context "No user is found in the DB with the given token" do
      before(:each) do
        User.stubs(:with_registration_token).with(anything).returns(nil)
      end
      it "should display an error message to the user" do
        put :update, user: {password: "mysecretpassword", password_confirmation: "mysecretpassword"} 
        flash[:notice].should_not be_empty 
      end
      it "should redirect to the login page" do 
        put :update, user: {password: "mysecretpassword", password_confirmation: "mysecretpassword"} 
        response.should redirect_to(new_session_path) 
      end
    end
  end
  
  describe "PasswordResetsController#create (POST)" do
    
    context "The user is found based on his/her email address" do
      it "should send an email with instructions to the user" do 
        post :create, email: @user.email
        ActionMailer::Base.deliveries.last.to.first.should eq(@user.email)
      end
      
      # XXX: Test the actual content? 
      it "should display a message to the user with instructions" do
        post :create, email: @user.email
        flash[:notice].should_not be_empty
      end

      it "should redirect to the login page" do
        post :create, email: @user.email
        response.should redirect_to(new_session_path)
      end

      it "should set a value for the user's registration_token" do
        post :create, email: @user.email
        assigns[:user].registration_token.should_not be_nil
      end
    end

    context "The user can't be found in the DB based on the email address he/she provided" do
      it "should display an error message explaining the issue" do
        post :create, email: @user.email
        flash[:notice].should_not be_empty
      end 
      
      it "should redirect the user to the login page" do 
        post :create, email: @user.email
        response.should redirect_to(new_session_path)
      end 
    end

  end

end
