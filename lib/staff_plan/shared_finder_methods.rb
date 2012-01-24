module StaffPlan::SharedFinderMethods
  
  private
  
  def find_target_user
    @target_user = User.find_by_id(params[:user_id] || params[:id])
    
    unless @target_user.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_user') and return
    end
  end
  
  def find_project
    @project = Project.find_by_id(params[:project_id] || params[:id])
    
    unless @project.present?
      redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_project') and return
    end
  end
  
  def find_or_create_client
    @client = Client.find_by_id(params[:client_id] || params[:id])
    
    unless @client.present?
      @client = Client.find_by_name(params[:client_name])
      
      unless @client.present?
        @client = Client.create(name: params[:client_name])
        
        if @client.new_record?
          redirect_to root_url, notice: I18n.t('controllers.shared.problem_finding_client') and return
        end
      end
    end
  end
  
  def find_client
    @client = Client.find_by_id(params[:client_id] || params[:id])
    
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