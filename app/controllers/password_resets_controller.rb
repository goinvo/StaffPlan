class PasswordResetsController < ApplicationController
  
  layout "registration"
  skip_before_filter :require_current_user
  
  def new
    # Display the form where the user provides an email address
  end

  def create
    @user = User.where(email: params[:email]).first
    if @user.present?
      @user.send_password_reset_instructions
      flash[:notice] = "Instructions have been sent to your email address. Please check your inbox."
    else
      # FIXME: Such a message is a cue about whether or not a given email address is in our DB 
      flash[:notice] = "We couldn't find your email address in the database, please try again"
    end
    redirect_to new_session_path
  end

  def edit
    @user = User.with_registration_token(params[:id])
    if @user.present?
      render
    else
      redirect_to new_session_path, notice: "Please create an account"
    end
  end

  def update
    @user = User.with_registration_token(params[:id])
    if @user.present?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        @user.registration_token = nil
        @user.save
        session[:user_id] = @user.id
        flash[:notice] = "Your password has been updated. Welcome back to StaffPlan"
        redirect_to staffplan_path(@user)
      else
        render action: :edit
      end
    else
      redirect_to new_session_path, notice: "Please create an account"
    end
  end
end
