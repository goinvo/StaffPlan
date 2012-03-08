require 'spec_helper'

describe StaffplansController do
  before(:each) do
    @current_user, @company = login_user

    3.times do |i|
      c = Factory(:client)
      2.times do |j|
        c.projects << Factory(:project)
      end
      instance_variable_set("@client_#{i+1}", c)
    end
  end

  describe 'GET#show' do
    it "should redirect to root_url if a user can't be found" do
      get :show, :id => "bogus"
      response.should be_redirect
      response.should redirect_to(root_url)
    end

    it "should redirect to root_url if the target user isn't in current_user.current_company.users" do
      target_user = user_with_clients_and_projects
      get :show, id: target_user.id
      response.should be_redirect
      response.should redirect_to(root_url)
    end

    it "should find the targeted user and populate some instance variables when the ID is valid" do
      target_user = user_with_clients_and_projects
      @company.users << target_user
      get :show, :id => target_user.id
      response.should be_success
      response.should render_template("staffplans/show")
      assigns[:target_user].should == target_user
      assigns[:clients].should_not be_nil
    end

    it "should show only clients and projects for the current user's current company when I go to my staff plan page" do
      
      @company.clients << @client_1

      @current_user.current_company.clients.should == [@client_1]

      get :show, id: @current_user.id

      # Current company is @company, which has one client (@client1), which has two projects 
      assigns[:clients].should_not be_nil
      assigns[:clients].first.class.should eq(String)
      assigns[:target_user].should == @current_user

      end

    it "should only show clients and projects for the current user's current company when I go to my staff plan page" do

      @other_company = Factory(:company)
      @other_company.clients << @client_2
      @other_company.clients << @client_3
      
      @other_company.users << @current_user
      
      @current_user.current_company = @other_company
      @current_user.save!
      @current_user.reload

      @current_user.current_company.clients.should_not include(@client_1)
      @current_user.current_company.clients.size.should eq(2)
      get :show, id: @current_user.id 

      assigns[:clients].should_not be_nil
      assigns[:target_user].should eq(@current_user)
    end

  end

end
