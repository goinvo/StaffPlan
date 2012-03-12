require 'spec_helper'

describe UsersController do

  before(:each) do
    @current_user, @company = login_user
  end

  describe "GET index" do
    it "assigns all users as @users" do
      get :index
      assigns(:users).should eq([@current_user])
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      user = Factory(:user)
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
      user = Factory(:user)
      @company.users << user
      get :edit, :id => user.id
      assigns(:user).should eq(user)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, :user => Factory.attributes_for(:user)
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, :user => Factory.attributes_for(:user)
        assigns(:user).should be_a(User)
        assigns(:user).should be_persisted
      end

      it "should set the current user's current_company_id on the newly created user" do
        post :create, :user => Factory.attributes_for(:user)
        assigns(:user).current_company_id.should eq(@company.id)
      end

      it "redirects to the created user" do
        post :create, :user => Factory.attributes_for(:user)
        response.should redirect_to(User.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save).returns(false)
        post :create, :user => {}
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save).returns(false)
        post :create, :user => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        user = Factory(:user)
        @company.users << user
        # Assuming there are no other users in the database, this
        # specifies that the User created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        User.any_instance.expects(:update_attributes).with('these' => 'params')
        put :update, :id => user.id, :user => {'these' => 'params'}
      end

      it "assigns the requested user as @user" do
        user = Factory(:user)
        @company.users << user
        put :update, :id => user.id, :user => Factory.attributes_for(:user)
        assigns(:user).should eq(user)
      end

      it "redirects to the user" do
        user = Factory(:user)
        @company.users << user
        put :update, :id => user.id, :user => Factory.attributes_for(:user)
        response.should redirect_to(user)
      end

      it "should let people change their current_company" do
        request.env["HTTP_REFERER"] = staffplan_url(@current_user)
        other_company = Factory(:company)
        other_company.users << @current_user
        put :update, :id => @current_user.id, :user => {current_company_id: other_company.id} 
        assigns[:user].current_company.should eq(other_company)
        response.should redirect_to :back
      end

      it "should just redirect to back and do nothing if the specified company_id is not one the user belongs to" do
        request.env["HTTP_REFERER"] = staffplan_url(@current_user)
        other_company = Factory(:company)
        lambda {
          put :update, :id => @current_user.id, :user => {current_company_id: other_company.id} 
        }.should_not change(@current_user, :current_company_id)
        response.should redirect_to :back
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = Factory(:user)
        @company.users << user
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save).returns(false)
        put :update, :id => user.id, :user => {}
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        user = Factory(:user)
        @company.users << user
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.expects(:save).returns(false)
        put :update, :id => user.id, :user => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = Factory(:user)
      @company.users << user
      expect {
        delete :destroy, :id => user.id
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = Factory(:user)
      @company.users << user
      delete :destroy, :id => user.id
      response.should redirect_to(users_url)
    end
  end

end
