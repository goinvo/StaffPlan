class ApplicationController < ActionController::Base

  protect_from_forgery

  has_mobile_fu
  before_filter :require_current_user, :require_current_company, :set_mobile_view

  protected 

  def find_target
    return unless %w(projects users clients).include? controller_name
    c = controller_name.singularize
    target = current_user.current_company.send(controller_name).find_by_id(params[:id])
    if target.present?
      instance_variable_set("@#{c}", target)
    else
      flash[:error] = "Couldn't locate or access the #{c}"
      redirect_to url_for(c.classify.constantize)
    end
  end

  private

  def require_current_company
    unless current_user.try(:current_company_id)
      redirect_to new_company_path
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def require_current_user 
    unless current_user.present?
      cookies[:original_request] = {value: Marshal.dump(request.path_parameters), expires: 2.minutes.from_now} if request.get?
      redirect_to new_session_url
    end
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
