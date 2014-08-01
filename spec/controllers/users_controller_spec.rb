require 'spec_helper'

describe UsersController do

  before(:each) do
    @current_user, @company = login_user
  end

  describe "GET index" do
    it "responds with JSON containing users" do
      get :index, format: 'json'
      response.body.match(@current_user.email).should be_present
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      user = FactoryGirl.create(:user)
      @company.users << user
      get :show, :id => user.id
      assigns(:user).should eq(user)
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      get :new
      assigns(:user).should be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      user = FactoryGirl.create(:user)
      @company.users << user
      get :edit, :id => user.id
      assigns(:user).should eq(user)
    end
  end

  describe "POST create" do
    before(:each) do
      @parameters = {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      }
    end

    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, :user => @parameters
        }.to change(User, :count).by(1)
      end

      it "should send an invitation to the newly created user" do
        post :create, user: @parameters
        ActionMailer::Base.deliveries.last.to.first.should eq(@parameters[:email])
      end

      it "assigns a newly created user as @user" do
        post :create, :user => @parameters
        assigns(:user).should be_a(User)
        assigns(:user).should be_persisted
      end

      it "should set the current user's current_company_id on the newly created user" do
        post :create, :user => @parameters
        assigns(:user).current_company_id.should eq(@company.id)
      end

      it "redirects to the created user" do
        post :create, :user => @parameters
        response.should redirect_to(User.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save_unconfirmed_user).returns(false)
        post :create, :user => {}
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save_unconfirmed_user).returns(false)
        post :create, :user => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do

      it "assigns the requested user as @user" do
        user = FactoryGirl.create(:user)
        @company.users << user
        put :update, :id => user.id, :user => FactoryGirl.attributes_for(:user)
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        user = FactoryGirl.create(:user)
        @company.users << user
        put :update, :id => user.id, :user => FactoryGirl.attributes_for(:user)
        response.should redirect_to(user)
      end
    end

    # describe "with invalid params" do
    #   it "assigns the user as @user" do
    #     user = FactoryGirl.create(:user)
    #     @company.users << user
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     User.any_instance.expects(:save).returns(false)
    #     put :update, :id => user.id, :user => {}
    #     assigns(:user).should eq(user)
    #   end
    #
    #   it "re-renders the 'edit' template" do
    #     user = FactoryGirl.create(:user)
    #     @company.users << user
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     User.any_instance.expects(:update_attributes).returns(false)
    #     put :update, :id => user.id, :user => {}
    #     response.should render_template("edit")
    #   end
    # end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = FactoryGirl.create(:user)
      @company.users << user
      expect {
        delete :destroy, :id => user.id
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = FactoryGirl.create(:user)
      @company.users << user
      delete :destroy, :id => user.id
      response.should redirect_to(users_url)
    end
  end

end
