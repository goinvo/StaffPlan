require 'spec_helper'
describe CompaniesController do

  before(:each) do
    @current_user, @company = login_user
  end

  describe "GET new" do
    it "should assign a new company to @company" do 
      get :new
      assigns[:company].should be_a_new(Company)
      assigns[:company].users.size.should eq(1)
      assigns[:user].should be_a_new(User)
    end
  end

  describe "POST create" do
    it "creates a new Company with valid params" do
      expect {
        post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
      }.to change(Company, :count).by(1)
    end
      
    it "should redirect to the user's staff plan page on successful company/user creation" do
      post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
      response.should redirect_to(root_url)
    end
      
    it "should create a new user and set the company's id as his/her current_company_id on a successful POST" do
      expect {
        post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
      }.to change(User, :count).by(1)
      
      assigns[:user].current_company_id.should eq(assigns[:company].id)
    end

    it "should redirect to companies/new if the company cannot be saved" do
      lambda {
        post :create, company: {name: ''}, user: Factory.attributes_for(:user) 
      }.should_not change(Company, :count)
        
      assigns[:company].should be_new_record
      flash[:errors].should_not be_empty
      response.should render_template(:new)
    end
    
    it "should not create a new company or user if the company save fails" do
      Company.any_instance.expects(:save).returns(false)
      
      post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user)
      
      assigns[:company].should be_new_record
      assigns[:user].should be_new_record
      response.should render_template(:new)
    end
    
    it "should not create a new company or user if the user association with the company fails" do
      user_attributes = Factory.attributes_for(:user); user_attributes.delete(:password)
      post :create, company: {name: Faker::Company.name}, user: user_attributes
      
      assigns[:company].should be_new_record
      assigns[:user].should be_new_record
      response.should render_template(:new)
    end
    
    it "should not set current_company_id on the user if the user has access to other companies" do
      user = Factory(:user); company = Factory(:company); company.users << user; user.current_company = company
      
      lambda {
        post :create, company: {name: Faker::Company.name}, user: { email: user.email }
      }.should_not change(User, :count)
        
      user.reload.current_company.should == company
    end
  end
end
