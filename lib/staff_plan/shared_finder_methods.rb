module StaffPlan::SharedFinderMethods
  
  private
  
  def find_target_user
    @target_user = current_user.current_company.users.find_by_id(params[:user_id] || params[:id])
    
    unless @target_user.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_user') and return
    end
  end
  
  def find_project
    @project = current_user.current_company.projects.find_by_id(params[:project_id] || params[:id])
    
    unless @project.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_project') and return
    end
  end
  
  def find_or_create_client
    @client = current_user.current_company.clients.find_by_id(params[:client_id] || params[:id])
    
    unless @client.present?
      client_name = params[:client_name].blank? ? Client::DEFAULT_CLIENT_NAME : params[:client_name]
      @client = current_user.current_company.clients.where(["lower(name) = ?", client_name.downcase]).first
      
      unless @client.present?
        @client = current_user.current_company.clients.create(name: client_name)
        @client.company_id = current_user.current_company_id
        
        unless @client.save
          redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_client') and return
        end
      end
    end
  end
  
  def find_client
    @client = current_user.current_company.clients.find_by_id(params[:client_id] || params[:id])
    
    unless @client.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_client') and return
    end
  end
  
  def find_work_week
    unless @project.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.project_required') and return
    end
    
    unless @target_user.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.user_required') and return
    end
    
    @work_week = @project.work_weeks.find_by_id(params[:id])
    
    unless @work_week.user == @target_user
      redirect_to root_url, notice: I18n.t('controllers.shared.user_mismatch') and return
    end
  end
end