require 'spec_helper'

describe Users::ProjectsController do
  
  before(:each) do
    @user = login_user
    @company = Factory(:company)
    @user.update_attributes(current_company_id: @company.id)
    @company.users << @user
  end
  
  describe 'all actions' do
    # TODO: shared example group
    it "should redirect if @target_user isn't found" do
      User.expects(:find_by_id).with(anything).times(3)
      
      post :create, :user_id => @user.id
      response.should redirect_to(root_url)
      
      put :update, :user_id => @user.id, :id => 'anything'
      response.should redirect_to(root_url)
      
      delete :destroy, :user_id => @user.id, :id => 'anything'
      response.should redirect_to(root_url)
    end
  end
  
  describe '#create' do
    
    before(:each) do
      @client_name = "Shiny New Client"
      @project_name = "Shiny New Project"
    end
    
    context "with new clients" do
      it "should create a new Client if a match can't be found" do
        lambda {
          post :create, :user_id => @user.id, :client_name => @client_name, :name => @project_name
        }.should change(Client, :count).by(1)
        
        client = Client.find_by_name(@client_name)
        client.should_not be_nil
        client.projects.map(&:name).should == [@project_name]
      end
      
      it "should assign the client to the current_user.current_company" do
        post :create, :user_id => @user.id, :client_name => @client_name, :name => @project_name
        @user.current_company.clients.find_by_name(@client_name).should_not be_nil
      end
      
      it "should redirect if the new Client fails to save" do
        lambda {
          post :create, :user_id => @user.id, :client_name => nil
        }.should_not change(Client, :count)
      end
    end
    
    context "with new OR existing clients" do
      # TODO: shared examples
      it "should render OK JSON if the project saves" do
        post :create, :user_id => @user.id, :client_name => @client_name, :name => @project_name
        response.should be_success
        response.body.match("\"status\":\"ok\"").should_not be_nil
        response.body.match("\"clients\":").should_not be_nil
        response.body.match("\"attributes\":").should_not be_nil
      end
      
      # TODO: shared examples
      it "should render FAIL JSON if the project doesn't save" do
        Project.any_instance.expects(:save).returns(false)
        post :create, :user_id => @user.id, :client_name => @client_name, :name => @project_name
        response.should be_success
        response.body.match("\"status\":\"fail\"").should_not be_nil
        response.body.match("\"errors\":").should_not be_nil
        response.body.match("\"attributes\":").should_not be_nil
      end
      
      it "should append the project to the target user's projects if the project saves" do
        @user.projects.map(&:name).should_not include(@project_name)
        post :create, :user_id => @user.id, :client_name => @client_name, :name => @project_name
        @user.reload.projects.map(&:name).should include(@project_name)
      end
    end
  end
  
  describe '#update' do
    # TODO: example groups
    it "should redirect if the project can't be found" do
      Project.expects(:find_by_id).with(anything)
      put :update, :user_id => @user.id, :id => 'anything'
      response.should redirect_to(root_url)
    end
    
    # TODO: shared examples
    it "should render OK JSON if the project updates" do
      put :update, :user_id => @user.id, :id => Factory(:project, :users => [@user]).id
      response.should be_success
      response.body.match("\"status\":\"ok\"").should_not be_nil
      response.body.match("\"clients\":").should_not be_nil
      response.body.match("\"attributes\":").should_not be_nil
    end
    
    # TODO: shared examples
    it "should render FAIL JSON if the project doesn't update" do
      Project.any_instance.expects(:update_attributes).with(anything).returns(false)
      put :update, :user_id => @user.id, :id => Factory(:project, :users => [@user]).id
      response.should be_success
      response.body.match("\"status\":\"fail\"").should_not be_nil
      response.body.match("\"errors\":").should_not be_nil
      response.body.match("\"attributes\":").should_not be_nil
    end
  end
  
  describe '#destroy' do
    # TODO: example groups
    it "should redirect if the project can't be found" do
      Project.expects(:find_by_id).with(anything)
      put :update, :user_id => @user.id, :id => 'anything'
      response.should redirect_to(root_url)
    end
    
    it "should remove the project from the target user's projects" do
      project = Factory(:project, :users => [@user])
      @user.reload.projects.map(&:name).should include(project.name)
      delete :destroy, :user_id => @user.id, :id => project.id
      @user.reload.projects.map(&:name).should_not include(project.name)
    end
  end
end
