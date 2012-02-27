class ApplicationController < ActionController::Base
  
  protect_from_forgery
  has_mobile_fu
  before_filter :require_current_user, :set_mobile_view
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def require_current_user
    redirect_to new_session_url unless current_user.present?
  end
  
  def set_mobile_view
    if params[:mobile_view].present?
      session[:mobile_view] = params[:mobile_view] == "true"
      set_mobile_format
    end
  end
end
