class ApplicationController < ActionController::Base
  
  protect_from_forgery
  respond_to_mobile_requests :skip_xhr_requests => false
  has_mobile_fu
  
  before_filter :require_current_user, :set_mobile_view
 
  protected 

  def find_target
    return unless %w(projects users clients).include? controller_name
    c = controller_name.singularize
    instance_variable_set("@#{c}", current_user.current_company.send(controller_name).find_by_id(params[:id]))
    if instance_variable_get("@#{c}").nil?
      flash[:error] = "Couldn't locate or access the #{c}"
      redirect_to url_for(c.classify.constantize)
    end
  end
 
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

  def set_mobile_view
    if params[:mobile_view].present?
      session[:mobile_view] = params[:mobile_view] == "true"
      set_mobile_format
    end
  end
end
