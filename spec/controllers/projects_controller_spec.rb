require 'spec_helper'

describe ProjectsController do
  
  render_views
  
  before(:each) do
    @current_user, @company = login_user
  end

  def valid_attributes(client= FactoryGirl.create(:client))
    attributes = {}
    attributes[:project] = FactoryGirl.attributes_for(:project)
    attributes[:project].delete(:client)
    attributes.merge!(client_id: client.id)
  end

  describe "GET index" do
    it "should render index" do
      get :index
      response.should render_template("index")
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = FactoryGirl.create(:project)
      @company.projects << project
      get :show, :id => project.id
      assigns(:project).should eq(project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      project = FactoryGirl.create(:project)
      @company.projects << project
      get :edit, :id => project.id
      assigns(:project).should eq(project)
    end
  end

  describe "POST create" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/json"
    end
    
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, valid_attributes
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, valid_attributes
        assigns(:project).should be_a(Project)
        assigns(:project).should be_persisted
      end

      it "redirects to the created project" do
        post :create, valid_attributes
        response.should be_success
        response.body.should_not be_blank
      end

      it "should assign the client to the new project if the user selects the client in the clients list" do
        client = FactoryGirl.create(:client, company: @company)
        post :create, project: {name: Faker::Company.name, client_id: "new", active: "1", assignment: {proposed: "0"}}, client_id: client.id
        assigns[:project].client.should_not be_nil
        assigns[:project].client.name.should eq(client.name)
        assigns[:project].client.company_id.should eq(@company.id)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {client_id: FactoryGirl.create(:client).id}
        assigns(:project).should be_a_new(Project)
      end

      it "responds with the invlaid project JSON attributes" do
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {}, client_id: FactoryGirl.create(:client).id
        response.content_type.should eq("application/json")
        json = JSON.parse(response.body)
        json["id"].should be_nil
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/json"
    end
    
    describe "with valid params" do
      it "updates the requested project" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        put :update, :id => project.id, :project => {name: new_name = "new name"}
        project.reload.name.should eq(new_name)
      end

      it "assigns the requested project as @project" do
        project = FactoryGirl.create(:project)
        Assignment.create(user_id: @current_user.id, project_id: project.id, proposed: true)
        @company.projects << project
        put :update, :id => project.id, :project => valid_attributes
        assigns(:project).should eq(project)
      end

      it "responds with a 200 JSON response" do
        project = FactoryGirl.create(:project)
        Assignment.create(user_id: @current_user.id, project_id: project.id, proposed: true)
        @company.projects << project
        put :update, :id => project.id, :project => {name: "new name"}
        response.should be_success
      end
      
      it "should save correctly when being passed all the params that backbone will send" do
        
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        put :update, :id => project.id, :project => {name: nil}
        assigns(:project).should eq(project)
      end

      it "renders JSON back with the name unchanged" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        put :update, :id => project.id, :project => {name: nil}
        json = JSON.parse(response.body)
        json["errors"].should_not be_blank
        json["errors"]["name"].should_not be_blank
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested project" do
      project = FactoryGirl.create(:project)
      @company.projects << project
      expect {
        delete :destroy, :id => project.id
      }.to change(Project, :count).by(-1)
    end

    it "respond with nothing" do
      project = FactoryGirl.create(:project)
      @company.projects << project
      delete :destroy, :id => project.id
      response.should be_success
      response.body.should be_blank
    end
  end

end
