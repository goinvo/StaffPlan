class RegistrationsController < ApplicationController

  skip_before_filter :require_current_user, :only => [:new, :create, :confirm]

  def new
    @user = User.new
    @company = @user.companies.build
    render layout: "registration"
  end

  def create
    @user = User.new(params[:user])
    @company = Company.new(params[:company])
    # Heavily inspired from CompaniesController, DRTW
    Company.transaction do
      if @company.save and @company.users << @user
        @user.current_company = @company if @user.current_company.nil?
        @company.administrator = @user
      else
        raise ActiveRecord::Rollback
      end
    end
    if @company.persisted?
      @user.send_registration_confirmation
      render template: "registrations/email_sent", layout: "registration"
    else
      @company.valid?
      @user.valid?
      render action: :new, layout: "registration"
    end
  end

  def confirm
    if (@user = User.with_registration_token(params[:token])).present?
      @user.registration_token = nil
      @user.registration_token_sent_at = nil
      @user.save
      session[:user_id] = @user.id
      redirect_to staffplan_path(@user), notice: "Hi #{@user.name}, welcome to StaffPlan"
    else
      redirect_to new_registration_path, notice: "Your token has expired, please register again"
    end
  end

  def invites
    if (@user = User.with_registration_token(params[:token])).present?
      redirect_to edit_user_path(@user), notice: "Almost done! Make sure to change your password."
    else
      render :text => "Your token has expired. Contact your StaffPlan company administrator at #{@user.current_company.administrator.email} to get a new invitation"
    end
  end

end
