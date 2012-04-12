require 'spec_helper'

describe Api::CompaniesController do

  describe "Api/CompaniesController#index (GET)" do
    context "The shared secret is valid" do
      context "should render a JSON array" do
        it "should render a JSON object" do
          get :index, format: "json", secret: StaffPlan::Application.config.api_secret
          response.headers['Content-Type'].should eq('application/json; charset=utf-8') 
        end

        it "should render an empty JSON array if no companies are found" do
          Company.destroy_all
          get :index, format: "json", secret: StaffPlan::Application.config.api_secret
          ActiveSupport::JSON.decode(response.body).should eq({'companies' => []})
        end

        it "should render a JSON array whose top-level key is 'companies'" do
          @company = company_with_users_and_projects 
          get :index, format: "json", secret: StaffPlan::Application.config.api_secret
          hash = ActiveSupport::JSON.decode(response.body)
          hash.keys.size.should eq(1)
          hash.keys.first.should eq('companies')
        end

        it "should return company name and the associated users and projects for each company" do
          @company = company_with_users_and_projects
          get :index, format: "json", secret: StaffPlan::Application.config.api_secret
          hash = ActiveSupport::JSON.decode(response.body)
          hash['companies'].all? do |company|
            { 'name' => String, 'users' => Array, 'projects' => Array }.all? do |key, type| 
              company.should have_key(key)
              company[key].should be_a(type)   
            end
          end
        end
      end
    end

    context "The shared secret is invalid" do
      it "should return a HTTP status code 403 to indicate that the access is forbidden" do
        get :index, secret: "bogus", format: "json"
        response.status.should eq(403)
        response.body.should eq("{}") 
      end
    end
  end

end
