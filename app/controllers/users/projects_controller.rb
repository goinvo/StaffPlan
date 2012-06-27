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
    
    if @project.users << @target_user and @project.save # @target_user.projects << @project
      render_json_ok
    else
      render_json_fail
    end
  end
  
  def update
    if @project.update_attributes(params[:project])
      render_json_ok
    else
      render_json_fail
    end
  end
  
  def destroy
    @target_user.projects.delete(@project)
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
