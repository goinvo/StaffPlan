class Users::Assignments::WorkWeeksController < ApplicationController
  include StaffPlan::WorkWeeksControllers
  
  private
  
  def find_work_week
    @work_week = @assignment.work_weeks.find(params[:id])
    
    unless @work_week.user == @target_user
      redirect_to root_url, notice: I18n.t('controllers.shared.user_mismatch') and return
    end
    
  rescue => e
    Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
  end
end