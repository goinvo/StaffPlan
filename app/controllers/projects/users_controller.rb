class Projects::UsersController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  
  def destroy
    @target_user.projects.delete(@project)
    render(:json => {
      status: 'ok'
    }) and return
  end
  
end