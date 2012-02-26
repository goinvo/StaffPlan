class StaffplansController < ApplicationController
  
  def show
    @target_user = current_user.current_company.users.where(id: params[:id]).first
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') and return unless @target_user.present?
    
    @target_user_json = @target_user.staff_plan_json
    @clients = Client.staff_plan_json
  end
  
  def index
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @to = 3.months.from_now(@from)
    
    @date_range = []
    start = @from.clone
    
    while start < @to
      @date_range << start
      start = start + 7.days
    end
    
    # Retrieve all users associated with the company the current user is currently viewing the pages for
    # as well as the associated projects and work_weeks estimates    
    @users = current_user.current_company.users.includes(projects: :work_weeks).all
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
