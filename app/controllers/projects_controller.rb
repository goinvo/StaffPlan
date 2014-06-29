class ProjectsController < ApplicationController
  
  respond_to :html, :json
  
  before_filter :find_target, only: [:show, :edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html {}
      format.json do
        render(json: current_user.current_company.projects)
      end
    end
  end
  
  def show
  end

  def create
    @project = Project.new params[:project]
    @project.client_id = params[:client_id]
    @project.company = current_user.current_company
    @project.save
    respond_with(@project)
  end

  def update
    @project.update_attributes(params[:project])
    respond_with(@project)
  end

  def destroy
    @project.destroy
    render(nothing: true)
  end
end
