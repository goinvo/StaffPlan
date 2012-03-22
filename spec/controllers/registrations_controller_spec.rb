require 'spec_helper'

describe RegistrationsController do

  context "with valid parameters" do
    before(:each) do
      @parameters = {}

      @parameters.store(:company, {
        name: Faker::Company.name
      })

      @parameters.store(:user, {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email, 
        password: "secret",
        password_confirmation: "secret"
      })
    end

    describe "GET#new" do
      it "should assign a new user to @user and a new company to @company" do
        get :new

        assigns(:user).should be_a_new(User)
        assigns(:company).should be_a_new(Company)
        assigns(:navigation_bar).should be_false
        response.should be_success
        response.should render_template(:new)
      end
    end

    describe "POST#create" do
      context "user/company creation somehow fails" do 
        it "should display errors to the user if the user they're trying to create already exists" do
          @user = Factory(:user)
          @parameters[:user].merge!({first_name: @user.first_name, last_name: @user.last_name})
          lambda {
            post :create, @parameters
          }.should_not change(User, :count)
          response.should render_template(:new)
        end

        it "should display errors to the user if the company they're trying to create already exists" do
          @company = Company.create(name: Faker::Company.name)
          @parameters[:company].merge!({name: @company.name})
          lambda {
            post :create, @parameters
          }.should_not change(Company, :count)
          response.should render_template(:new)
        end

        it "should not add the newly created user to a pre-existing company if the company name provided already exists" do
          @company = Company.create(name: Faker::Company.name)
          @parameters[:company].merge!({name: @company.name})
          lambda {
            post :create, @parameters
          }.should_not change(@company.users, :size)
        end

        it "should display errors to the user if the email they're using is invalid" do
          @parameters[:user].merge!({email: "bogus"})
          company_count = Company.count
          user_count = User.count
          post :create, @parameters
          response.should render_template(:new)
          Company.count.should eq(company_count)
          User.count.should eq(user_count)
        end
      end

      context "user/company creation succeeds" do
        it "should render a page notifying the user that an email was sent to him" do
          post :create, @parameters
          response.should render_template(:email_sent) 
        end

        it "should send an email to the user with a link to finalize his registration" do
          User.any_instance.expects(:send_registration_confirmation)
          post :create, @parameters
        end

        it "should send the email to the proper user" do
          post :create, @parameters
          ActionMailer::Base.deliveries.last.to.first.should eq(@parameters[:user][:email])
        end

        it "should send an actual email to the user" do
          lambda {
            post :create, @parameters
          }.should change(ActionMailer::Base.deliveries, :size).by(1)
        end

        it "should add a company to the database" do
          company_count = Company.count
          lambda {
            post :create, @parameters
          }.should change(Company, :count).from(company_count).to(company_count + 1)
        end

        it "should set a token and its related timestamp on the user" do
          post :create, @parameters
          assigns(:user).registration_token.should_not be_nil
          assigns(:user).registration_token_sent_at.should > 10.seconds.ago
        end

        it "should add a user to the database" do
          user_count = User.count
          lambda {
            post :create, @parameters
          }.should change(User, :count).from(user_count).to(user_count + 1)
        end
      end
    end

    describe "PUT#confirm" do
      context "User is found with his token" do
        it "should reset the user's registration token and its timestamp to nil and redirect to his/her staffplan page" do
          @user = Factory(:user)
          @user.registration_token = SecureRandom.urlsafe_base64
          @user.registration_token_sent_at = 30.minutes.ago
          User.stubs(:with_registration_token).with(anything).returns(@user)
          put :confirm, token: "whatevs" # We'll get @user from the stub anyway
          @user.registration_token.should be_nil
          @user.registration_token_sent_at.should be_nil
          response.should redirect_to(staffplan_path(@user))
          flash[:notice].should_not be_nil
        end
      end

      it "should set the user as the current user by stuffing his id in session" do
        @user = Factory(:user)
        @user.registration_token = SecureRandom.urlsafe_base64
        @user.registration_token_sent_at = 30.minutes.ago
        User.stubs(:with_registration_token).with(anything).returns(@user)
        put :confirm, token: "donkey"
        session[:user_id].should eq(@user.id)
      end

      context "User is NOT found with his token" do
        it "should redirect to the registration page if the user cannot be found" do
          # Kind of redundant since we're feeding a bullshit token anyway but...
          User.stubs(:with_registration_token).with(anything).returns(nil)
          put :confirm, token: "-sad9ad99das9ddsss_"
          flash[:notice].should_not be_empty
          response.should redirect_to(new_registration_path)
        end
      end
    end

    describe "PUT#invites" do
      it "should redirect to the invited user's edit user page on successful invitation" do
        @user = Factory(:user)
        User.stubs(:with_registration_token).with(anything).returns(@user)
        put :invites, token: "bogus"
        response.should redirect_to edit_user_path(@user)
      end

      it "should set the invited user as the current user on a successful invite" do
        @user = Factory(:user)
        @user.registration_token = SecureRandom.urlsafe_base64
        @user.registration_token_sent_at = 30.minutes.ago
        User.stubs(:with_registration_token).with(anything).returns(@user)
        put :invites, token: "whatevs"
        session[:user_id].should eq(@user.id)
      end
    end

  end

  context "with invalid parameters" do 

  end

end
