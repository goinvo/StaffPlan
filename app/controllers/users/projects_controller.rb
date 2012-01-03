class Users::ProjectsController < ApplicationController
  
  before_filter :find_target_user
  before_filter :find_project, :only => [:update, :destroy]
  before_filter :find_client, :only => [:create]
  
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
  
  private
  
  def find_target_user
    @target_user = User.find_by_id(params[:user_id])
    
    unless @target_user.present?
      flash.error I18n.t('controllers.users.problem_finding_user')
      redirect_to root_url and return
    end
  end
  
  def find_project
    @project = Project.find_by_id(params[:id])
    
    unless @project.present?
      flash.error I18n.t('controllers.users.problem_finding_project')
      redirect_to root_url and return
    end
  end
  
  def find_client
    @client = Client.find_by_id(params[:client_id])
    
    unless @client.present?
      flash.error I18n.t('controllers.users.problem_finding_client')
      redirect_to root_url and return
    end
  end
end
