class StaffplansController < ApplicationController
  
  def show
    @target_user = User.where(id: params[:id]).first
    
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') unless @target_user.present?
    
    @target_user_json = @target_user.to_json(only: [:id, :name, :email], 
                                             include: { projects:
                                               { include: :work_weeks,
                                                 only: [:name, :id, :client_id] }
                                              }
                                            )
    @clients = Client.all
  end
  
end
