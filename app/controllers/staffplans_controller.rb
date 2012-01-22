class StaffplansController < ApplicationController
  
  def show
    @target_user = User.where(id: params[:id]).first
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') and return unless @target_user.present?
    
    @target_user_json = @target_user.staff_plan_json
    @clients = Client.joins(:projects).all
  end
end
