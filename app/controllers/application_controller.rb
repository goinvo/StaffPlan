class ApplicationController < ActionController::Base
  
  protect_from_forgery
  respond_to_mobile_requests :skip_xhr_requests => false
  
  before_filter :require_current_user
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def require_current_user
    redirect_to new_session_url unless current_user.present?
  end

  def render_not_found
    render file: File.join(Rails.root, "public", "404.html"), layout: false, status: :not_found
  end
end
