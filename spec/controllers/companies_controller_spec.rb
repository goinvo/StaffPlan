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
    context "with valid params" do
      it "creates a new Company" do
        expect {
          post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
        }.to change(Company, :count).by(1)
      end
      it "should redirect to the user's staff plan page on successful company/user creation" do
        post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
        response.should redirect_to(root_url)
      end

      it "should not save anything if the new user's name already exists" do
        parameters = {
          company: Factory.attributes_for(:company), 
          user: Factory.attributes_for(:user).merge(name: @current_user.name)
        } 
        lambda {
          post :create, parameters
        }.should_not change(User, :count)
        flash[:errors].should_not be_empty
        response.should render_template(:new)
      end

      it "should redirect to companies/new if the company cannot be saved" do
        # How does one test the flash[:errors] since there's no real way to make 
        # @company.save fail (no validation whatsoever)
        Company.any_instance.expects(:save).returns(false)
        lambda {
          post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
        }.should_not change(Company, :count)
        assigns[:company].should be_new_record
        response.should render_template(:new)
      end
    end
  end
end
