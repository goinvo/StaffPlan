class ProjectsController < ApplicationController
  
  respond_to :json
  
  before_filter only: [:show, :edit, :update, :destroy] do |c|
    c.find_target
  end
  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.current_company.projects.sort do |a,b|
      a.name.downcase <=> b.name.downcase
    end
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
    @project = Project.new params[:project]
    @project.client_id = params[:client_id]
    @project.company_id = params[:company_id]

    if @project.save
      respond_to do |format|
        format.json { render :json => @project }
      end
    else
      respond_to do |format|
        format.json { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
    # client = Client.find_by_id(params[:client_id])
    
    # unless client.present?
    #   render json: {status: :unprocessable_entity} and return
    # end
    
    # @project = current_user.current_company.projects.build(params[:project].merge(client: client))

    # if @project.save
    #   respond_with @project and return
    # else
    #   render json: {status: :unprocessable_entity}
    # end
  end

  def edit
    @assignment = @project.assignments.where(user_id: current_user.id).first 
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        # The user just updated the project, we need to update the proposed state for this assignment if needed
        # @project.assignments.where(user_id: current_user.id).first.update_attributes(params[:project][:assignment])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render json: @project, status: :ok } 
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
