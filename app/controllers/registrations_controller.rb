class RegistrationsController < ApplicationController
  layout "registration"
  skip_before_filter :require_current_user, :only => [:new, :create, :confirm, :complete]

  def new
    @user = User.new
    @company = @user.companies.build
  end

  def create
    @user = User.new(params[:user])
    @company = Company.new(params[:company])
    
    # Heavily inspired from CompaniesController, DRTW
    Company.transaction do
      if @company.save and @company.users << @user
        @user.current_company = @company if @user.current_company.nil?
      else
        raise ActiveRecord::Rollback
      end
    end
    
    if @company.persisted?
      @user.send_registration_confirmation
      render template: "registrations/email_sent"
    else
      # I have to call valid? here or I don't get the error messages for the user 
      flash[:errors] = {}
      [@user, @company].each do |obj| 
        flash[:errors].merge!(obj.class.name.downcase => obj.errors) unless obj.valid?
      end
      redirect_to new_registration_path
    end
  end
  
  def complete
    if @user = User.with_registration_token(params[:token])
      @user.password = params[:user] ? params[:user][:password] : nil
      @user.password_confirmation = nil
      @user.registration_token = nil
      
      if @user.save
        session[:user_id] = @user.id
        redirect_to staffplan_path(@user), notice: "Hi #{@user.full_name}, welcome to StaffPlan!"
      else
        if @user.errors.keys.include?(:password_digest)
          @user.errors.delete(:password_digest)
          @user.errors.add(:password, "can't be blank.")
        end
        
        flash[:errors] = {"user" => @user.errors}
        redirect_to confirm_registration_path(token: params[:token])
      end
    else
      redirect_to new_registration_path, notice: "Welcome to StaffPlan, please register!"
    end
    
  end
  
  def confirm
    unless @user = User.with_registration_token(params[:token])
      redirect_to new_registration_path, notice: "Welcome to StaffPlan, please register!"
    else
      unless @user.password_digest.blank?
        @user.registration_token = nil
        @user.save
        session[:user_id] = @user.id
        redirect_to(staffplan_path(@user), notice: "Welcome to StaffPlan!") and return
      end
    end
  end

end
