module StaffPlan::SharedFinderMethods
  
  private
  
  def find_target_user
    @target_user = User.find_by_id(params[:user_id] || params[:id])
    
    unless @target_user.present?
      flash.error I18n.t('controllers.shared.problem_finding_user')
      redirect_to root_url and return
    end
  end
  
  def find_project
    @project = Project.find_by_id(params[:project_id] || params[:id])
    
    unless @project.present?
      flash.error I18n.t('controllers.shared.problem_finding_project')
      redirect_to root_url and return
    end
  end
  
  def find_client
    @client = Client.find_by_id(params[:client_id] || params[:id])
    
    unless @client.present?
      flash.error I18n.t('controllers.shared.problem_finding_client')
      redirect_to root_url and return
    end
  end
  
  def find_work_week
    unless @project.present?
      flash.error I18n.t('controllers.shared.project_required')
      redirect_to root_url and return
    end
    
    unless @target_user.present?
      flash.error I18n.t('controllers.shared.user_required')
      redirect_to root_url and return
    end
    
    @work_week = @project.work_weeks.find_by_id(params[:id])
    
    unless @work_week.user == @target_user
      flash.error I18n.t('controllers.shared.user_mismatch')
      redirect_to root_url and return
    end
  end
end