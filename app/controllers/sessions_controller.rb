class SessionsController < ApplicationController
  
  skip_before_filter :require_user, :except => [:destroy]
  
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, :notice => t(:hello)
    else
      flash.now.alert = t(:invalid_password_or_email)
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => t(:goodbye)
  end
end
