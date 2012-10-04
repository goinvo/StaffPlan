class StaffplansController < ApplicationController
  
  def show
    respond_to do |format|
      format.html {}
      format.mobile do
        @target_user = User.where(id: params[:id]).first
        @date = (Date.parse(params[:date]) rescue Date.today).at_beginning_of_week
        @projects = @target_user.assignments.map(&:project).group_by { |project| project.client.name }
        render(layout: false) if request.xhr?
      end
    end
  end
 
  def inactive
    @users = UserDecorator.decorate(current_user.current_company.inactive_users.sort { |a,b| a.last_name <=> b.last_name })
  end

  def index
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
