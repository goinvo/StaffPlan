class Users::UserPreferencesController < ApplicationController
  
  respond_to :json
  
  def update
    @user = User.where(:id => params[:user_id]).first
    @user.create_user_preferences if @user.user_preferences.nil?
    respond_to do |format|
      format.json do
        if @user.user_preferences.update_attributes(whitelist_attributes(params[:user_preference]))
          render :json => {:status => :ok}
        else
          render :json => {:status => :unprocessable_entity}
        end
      end
    end
  end

  private

  def whitelist_attributes(parameters)
    parameters.slice(:email_reminder)
  end

end
