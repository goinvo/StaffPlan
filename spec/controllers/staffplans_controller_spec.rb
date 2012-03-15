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

    context "mobile" do
      before(:each) do
        visited_user = user_with_clients_and_projects
        @company.users << visited_user
        @parameters = {id: visited_user.id, format: "mobile"}
      end

      it "should assign the beginning of the current week to @date if the user doesn't pass any date parameter" do
        get :show, @parameters 
        assigns[:date].should eq(Date.today.at_beginning_of_week)
      end

      it "should assign the beginning of the week for the date passed as a parameter if the user supplies a valid one" do
        date = rand(1..6).weeks.ago(Date.today).strftime("%Y-%m-%d")
        get :show, @parameters.merge(date: date)
        assigns[:date].should eq(Date.parse(date).at_beginning_of_week)
      end

      it "should assign the beginning of the current week to @date if the user supplies an invalid date parameter" do
        get :show, @parameters.merge(date: "bogus") 
        assigns[:date].should eq(Date.today.at_beginning_of_week)
      end

      it "should assign a list of projects grouped by client name to @projects" do
        get :show, @parameters
        assigns[:projects].should be_a(Hash)
        assigns[:projects].all? do |client_name, projects|
          projects.all? do |project| 
            project.client.name.should eq(client_name)
          end
        end
      end

      it "should render the show.mobile.haml template with no layout for a XHR request" do
        xhr :get, :show, @parameters
        response.should render_template("staffplans/show", layout: false)
      end
    end

  end

  describe "GET#my_staffplan" do
    it "should redirect the current_user to his/her staffplan page" do
      get :my_staffplan
      response.should redirect_to(staffplan_url(@current_user))
    end
  end

  describe "GET#index" do 
    context "General" do
      it "should assign @users with a list of users ordered by ascending estimated workload in the future" do
        @company.users << Array.new(3) { user_with_clients_and_projects }
        get :index
        assigns[:users].should_not be_empty
        users = assigns[:users].map{|u| u.plan_for(@company.id)}
        users.sort.should == users
      end

      it "should show the index template" do
        get :index
        response.should render_template(:index)
      end

      it "should only show workload estimates for users belonging to the current user's current company" do
        @company.users << user_with_clients_and_projects
        other_user = user_with_clients_and_projects
        other_company = Factory(:company)
        other_company.users << other_user
        get :index
        assigns[:users].size.should eq(@company.users.size)
        assigns[:users].should_not include(other_user)
      end

      it "should assign an array of Date objects to @date_range" do
        get :index
        assigns[:date_range].should be_a(Array)
        assigns[:date_range].all? do |date| 
          date.should be_a(Date)
        end
      end
    end

    context "I want to see the staffplans for the next 3 months" do
      it "should assign the time frame going from one week ago to the week before 3 months from now to @date_range" do
        get :index
        assigns[:from].should eq(1.week.ago(Date.today.at_beginning_of_week))
        assigns[:date_range].first.should eq(assigns[:from])
        assigns[:date_range].last.should < 3.month.from_now(assigns[:from])
      end
    end

    context "I want to see the staff plans for a period of 3 months from the given date" do
      it "should fall back to showing the staff plans for the next three months if I pass an invalid from parameter" do
        get :index, from: "bogus"
        assigns[:from].should eq(1.week.ago(Date.today.at_beginning_of_week))
      end

      it "should assign the time frame going from one week before the given date to the week before 3 months after that date to @date_range" do
        from_date = rand(1..100).days.ago.strftime("%Y-%m-%d")
        get :index, from: from_date 
        assigns[:from].should eq(1.week.ago(Date.parse(from_date).at_beginning_of_week))
        assigns[:date_range].first.should eq(assigns[:from])
        assigns[:date_range].last.should < 3.month.from_now(assigns[:from])
      end 
    end
  end

end
