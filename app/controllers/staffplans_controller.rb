class StaffplansController < ApplicationController
  
  def show
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @from = 1.week.ago(@from)
    @target_user = current_user.current_company.users.find_by_id(params[:id])
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') and return unless @target_user.present?
    
    respond_to do |format|
      format.html do
        @target_user_json = @target_user.staff_plan_json(current_user.current_company_id)
        @clients = current_user.current_company.clients_as_json
      end
    
      format.mobile do
        @date = (Date.parse(params[:date]) rescue Date.today).at_beginning_of_week
        @projects = @target_user.projects.group_by { |project| project.client.name }
        render(layout: false) if request.xhr?
      end
    end
  end
  
  def index
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @from = 1.week.ago(@from)
    @to = 3.months.from_now(@from)
    
    @date_range = []
    start = @from.clone
    
    while start < @to
      @date_range << start
      start = start + 7.days
    end
    
    project_ids = current_user.current_company.projects.map(&:id)
    @users = current_user.current_company.active_users.includes(:projects).all.sort { |a, b| a.plan_for(project_ids, @from) <=> b.plan_for(project_ids, @from) }
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
