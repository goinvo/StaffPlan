class StaffplansController < ApplicationController
  def show
    respond_to do |format|
      format.mobile do
        @target_user = User.where(id: params[:id]).first
        @date = (Date.parse(params[:date]) rescue Date.today).at_beginning_of_week
        @assignments = @target_user.assignments.group_by { |assignment| assignment.project.client.name }
        render(layout: false) if request.xhr?
      end
    end
  end
 
  def inactive
  end

  def index
    respond_to do |format|
      format.html {}
      format.mobile do
        @start = params[:from] # We need to save that for the view
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
        u = current_user.current_company.active_users.sort do |a, b|
          a.last_name <=> b.last_name
        end
        @users = UserDecorator.decorate(u)
      end
    end
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
