require 'spec_helper'
  describe CompaniesController do

  before(:each) do
    login_user
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
    describe "with valid params" do
      it "creates a new Company" do
        expect {
          post :create, company: {name: Faker::Company.name}, user: Factory.attributes_for(:user) 
        }.to change(Company, :count).by(1)
      end
    end
  end

end
