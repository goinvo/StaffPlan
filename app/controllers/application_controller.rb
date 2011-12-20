class ApplicationController < ActionController::Base
  
  protect_from_forgery
  force_ssl
  respond_to_mobile_requests :skip_xhr_requests => false
  
  before_filter :require_user
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def require_user
    redirect_to new_session_url unless current_user.present?
  end
end
