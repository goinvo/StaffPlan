require 'spec_helper'

describe ProjectsController do

  before(:each) do
    @current_user = login_user
    @company = Factory(:company)
    @current_user.update_attributes(current_company_id: @company.id)
    @company.users << @current_user
  end

  def valid_attributes(client = Factory(:client))
    attributes = Factory.attributes_for(:project)
    attributes.delete(:client)
    attributes.merge!(client_id: client.id)
  end

  describe "GET index" do
    it "assigns all projects as @projects but only returns projects associated to the current user's account" do
      project = Factory(:project)

      @company.projects << project

      get :index
      # Now you see me
      assigns(:projects).should eq([project])

      @company.projects.delete_all
      get :index
      # Now you don't
      assigns(:projects).should eq([])
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = Factory(:project)
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
      project = Factory(:project)
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
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {client_id: Factory(:client).id}
        assigns(:project).should be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        post :create, :project => {client_id: Factory(:client).id}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        project = Factory(:project)
        @company.projects << project
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.expects(:update_attributes).with('these' => 'params')
        put :update, :id => project.id, :project => {'these' => 'params'}
      end

      it "assigns the requested project as @project" do
        project = Factory(:project)
        @company.projects << project
        put :update, :id => project.id, :project => valid_attributes
        assigns(:project).should eq(project)
      end

      it "redirects to the project" do
        project = Factory(:project)
        @company.projects << project
        put :update, :id => project.id, :project => valid_attributes
        response.should redirect_to(project)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = Factory(:project)
        @company.projects << project
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.expects(:save).returns(false)
        put :update, :id => project.id, :project => {}
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        project = Factory(:project)
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
      project = Factory(:project)
      @company.projects << project
      expect {
        delete :destroy, :id => project.id
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      project = Factory(:project)
      @company.projects << project
      delete :destroy, :id => project.id
      response.should redirect_to(projects_url)
    end
  end

end
