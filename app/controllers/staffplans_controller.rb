class StaffplansController < ApplicationController
  
  def show
    @target_user = User.where(id: params[:id]).first
    @target_user_json = @target_user.to_json(only: [:id, :name, :email], 
                                             include: { projects:
                                               { include: :work_weeks,
                                                 only: [:name, :id, :client_id] }
                                              }
                                            )
    @clients = Client.all
  rescue ActiveRecord::RecordNotFound => e
    flash.alert = I18n.t('controllers.staffplans.couldnt_find_user')
    redirect_to root_url
  end
  
end
