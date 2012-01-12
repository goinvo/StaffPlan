class Users::ProjectsController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  before_filter :find_or_create_client, :only => [:create]
  
  def create
    @project = Project.new(client: @client, name: params[:name])
    
    if @project.save
      @target_user.projects << @project
      
      render(:json => {
        status: 'ok',
        model: @project
      })
    else
      render(:json => {
        status: 'fail',
        model: @project
      })
    end
  end
  
  def destroy
    @target_user.projects.delete(@project)
    render(:json => {
      status: 'ok'
    })
  end
end
