class Users::ProjectsController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  before_filter :find_or_create_client, :only => [:create]
  
  def create
    @project = @client.projects.where(["lower(name) = ?", (params[:name] || '').downcase]).first
    
    if @project.nil?
      @project = @client.projects.build(name: params[:name])
      @project.company_id = current_user.current_company_id
    end
    
    if (@target_user.projects << @project rescue false)
      render_json_ok
    else
      render_json_fail
    end
  end
  
  def update
    if params.try(:[], :project).try(:[], :assignment).present?
      @project.assignments.where(user_id: params[:user_id]).first.update_attributes(params[:project][:assignment])
    end
    if params.try(:[], :project) && @project.update_attributes(params[:project].except(:assignment))
      render_json_ok
    else
      render_json_fail
    end
  end
  
  def destroy
    @target_user.assignments.where(project_id: @project.id).first.try(:destroy)
    render(:json => {
      status: 'ok'
    }) and return
  end
  
  private
  
  def render_json_ok
    render(json: {
      status: "ok",
      clients: current_user.current_company.clients.includes(:projects).map(&:staff_plan_json),
      attributes: @project
    }) and return
  end
  
  def render_json_fail
    render(json: {
      status: 'fail',
      attributes: @project,
      errors: @project.errors.full_messages
    }) and return
  end
end
