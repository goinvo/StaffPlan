class Projects::UsersController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  
  def update
    if @project.users << @target_user
      render(json: {
        users: @project.users.map { |u| u.project_json(@project) }
      }) and return
    else
      render(json: {
        status: 'fail'
      }) and return
    end    
  end
  
  def destroy
    @target_user.projects.delete(@project)
    render(:json => {
      status: 'ok'
    }) and return
  end
  
end