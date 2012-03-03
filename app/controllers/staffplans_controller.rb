class StaffplansController < ApplicationController
  
  def show
    @target_user = current_user.current_company.users.find_by_id(params[:id])
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') and return unless @target_user.present?
    
    respond_to do |format|
      format.html do
        @target_user_json = @target_user.staff_plan_json(current_user.current_company_id)
        @clients = current_user.current_company.clients_as_json
      end
    
      format.mobile do
        @date = (params[:date].present? ? Date.parse(params[:date]) : Date.today.at_beginning_of_week).at_beginning_of_week
        @projects = @target_user.projects.inject({}) do |hash, project|
          hash[project.client.name] ||= []
          hash[project.client.name] << project
          hash
        end
        
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
    
    # Retrieve all users associated with the company the current user is currently viewing the pages for
    # as well as the associated projects and work_weeks estimates    
    @users = current_user.current_company.users.includes(projects: :work_weeks).order("name ASC").all
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
