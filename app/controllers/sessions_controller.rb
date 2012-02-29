class SessionsController < ApplicationController
  
  skip_before_filter :require_current_user, :except => [:destroy]
  
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      # TODO: redirect to the originally requested resource if it was a GET request
      redirect_to root_url, :notice => t(:hello)
    else
      flash.alert = t(:invalid_password_or_email)
      redirect_to new_session_url
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => t(:goodbye)
  end
end
