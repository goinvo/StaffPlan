class ProjectsController < ApplicationController
  before_filter only: [:show, :edit, :update, :destroy] do |c|
    c.find_target
  end
  # GET /projects
  # GET /projects.json
  def index
    # A project belongs_to a company/account
    # Let's retrieve all the projects associated with the account
    # the current_user is currently browsing the app through
    @projects = current_user.current_company.projects 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @company_users_json = current_user.current_company.users.as_json(only: [:name, :email, :id]).to_s
    @clients = current_user.current_company.clients_as_json
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    client = params[:client].present? ? Client.new(params[:client]) : Client.find_by_id(params[:project].delete(:client_id))
    unless client.present?
      redirect_to projects_url, notice: "Client is required." and return
    end
    
    @project = Project.new(params[:project])
    @project.client = client

    respond_to do |format|
      if @project.save
        current_user.current_company.projects << @project
        current_user.current_company.clients << @project.client
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :ok }
    end
  end

end
