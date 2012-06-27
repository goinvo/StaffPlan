class Projects::UsersController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  
  def update
    if @project.users << @target_user
      render(json: {
        users: @project.users.map { |u| UserDecorator.decorate(u).project_json(@project) }
      }) and return
    else
      render(json: {
        status: 'fail'
      }) and return
    end    
  end
  
  def destroy
    User.transaction do
      @target_user.projects.delete(@project)
      @target_user.work_weeks.for_project(@project).map(&:destroy)
    end
    
    render(:json => {
      status: 'ok'
    }) and return
  end
  
end
