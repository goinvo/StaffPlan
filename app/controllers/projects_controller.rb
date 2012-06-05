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
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @from = 1.week.ago(@from)
    @to = 3.months.from_now(@from)
    
    @date_range = []
    start = @from.clone
    
    while start < @to
      @date_range << start
      start = start + 7.days
    end

    @totals_per_week, @max_size = *current_user.current_company.total_recap_for_date_range(@date_range.first, @date_range.last)
    @projects = ProjectDecorator.decorate(current_user.current_company.projects.sort do |a,b|
      a.name.downcase <=> b.name.downcase
    end)
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
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @from = 1.week.ago(@from)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
    @assignment = @project.assignments.build(user_id: current_user.id) 
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
        Assignment.create({project_id: @project.id, user_id: current_user.id}.merge(params[:project][:assignment]))
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

  def edit
    @assignment = @project.assignments.where(user_id: current_user.id).first 
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      # The user just updated the project, we need to update the proposed state for this assignment if needed
      @project.assignments.where(user_id: current_user.id).first.update_attributes(params[:project][:assignment])
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
