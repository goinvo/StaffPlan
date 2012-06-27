require 'spec_helper'

describe ProjectsController do

  before(:each) do
    @current_user, @company = login_user
  end

  def valid_attributes(client= FactoryGirl.create(:client))
    attributes = FactoryGirl.attributes_for(:project)
    attributes.delete(:client)
    attributes.merge!(client_id: client.id)
    attributes.merge!({assignment: {:proposed => "1"}})
  end

  describe "GET index" do
    it "assigns all projects as @projects but only returns projects associated to the current user's account" do
      project = FactoryGirl.create(:project)

      @company.projects << project

      get :index
      assigns(:projects).should eq([project])

      @company.projects.destroy_all

      get :index
      assigns(:projects).should eq([])
    end

    it "should return projects ordered by name" do
      3.times do
        @company.projects << FactoryGirl.create(:project)
      end
      get :index
      names = assigns(:projects).map(&:name)
      (names[0] <= names[1] and names[1] <= names[2]).should be_true
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

  describe "GET new" do
    it "assigns a new project as @project" do
      get :new
      assigns(:project).should be_a_new(Project)
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
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, :project => valid_attributes
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, :project => valid_attributes
        assigns(:project).should be_a(Project)
        assigns(:project).should be_persisted
      end

      it "redirects to the created project" do
        post :create, :project => valid_attributes
        response.should redirect_to(Project.last)
      end

      it "should create a new client if the user selects New Client in the client list" do 
        expect {
          post :create, project: {name: Faker::Company.name, client_id: "new", active: "1", assignment: {proposed: "1"}}, client: {name: Faker::Company.name}
        }.to change(Client, :count).by(1)
      end

      it "should assign the new client to the new project if the user selects New Client in the clients list" do
        client_name = Faker::Company.name
        post :create, project: {name: Faker::Company.name, client_id: "new", active: "1", assignment: {proposed: "0"}}, client: {name: client_name}
        assigns[:project].client.should_not be_nil
        assigns[:project].client.name.should eq(client_name)
        assigns[:project].client.company_id.should eq(@company.id)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {client_id: FactoryGirl.create(:client).id}
        assigns(:project).should be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {client_id: FactoryGirl.create(:client).id}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.expects(:update_attributes).with('these' => 'params')
        put :update, :id => project.id, :project => {'these' => 'params'}
      end

      it "assigns the requested project as @project" do
        project = FactoryGirl.create(:project)
        Assignment.create(user_id: @current_user.id, project_id: project.id, proposed: true)
        @company.projects << project
        put :update, :id => project.id, :project => valid_attributes
        assigns(:project).should eq(project)
      end

      it "redirects to the project" do
        project = FactoryGirl.create(:project)
        Assignment.create(user_id: @current_user.id, project_id: project.id, proposed: true)
        @company.projects << project
        put :update, :id => project.id, :project => valid_attributes
        response.should redirect_to(project)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        put :update, :id => project.id, :project => {}
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        project = FactoryGirl.create(:project)
        @company.projects << project
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        put :update, :id => project.id, :project => {}
        response.should render_template("edit")
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

    it "redirects to the projects list" do
      project = FactoryGirl.create(:project)
      @company.projects << project
      delete :destroy, :id => project.id
      response.should redirect_to(projects_url)
    end
  end

end
