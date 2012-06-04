class StaffplansController < ApplicationController
  
  def show
    c = current_user.current_company
    @from = Date.parse(params[:from] || '').at_beginning_of_week rescue Date.today.at_beginning_of_week
    @from = 1.week.ago(@from)
    @target_user = UserDecorator.new(c.users.find_by_id(params[:id]))
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') and return unless @target_user.model.present?
    
    respond_to do |format|
      format.html do
        @target_user_json = @target_user.staff_plan_json(c.id)
        @clients = c.clients_as_json
      end
    
      format.mobile do
        @date = (Date.parse(params[:date]) rescue Date.today).at_beginning_of_week
        @projects = @target_user.projects.group_by { |project| project.client.name }
        render(layout: false) if request.xhr?
      end
    end
  end
  
  def index
    @start = params[:from] # We need to save that for the view
    @sort ||= params[:sort]
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
    u = current_user.current_company.users.sort do |a, b|
      if @sort.nil? || @sort == "workload"
        a.plan_for(project_ids, @date_range.first) <=> b.plan_for(project_ids, @date_range.first)
      else
        a.last_name <=> b.last_name
      end 
    end
    @users = UserDecorator.decorate(u)

    
    @workload = WorkWeek.staffplans_for_company_and_date_range(current_user.current_company, @date_range)
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
