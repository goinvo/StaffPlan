class CompaniesController < ApplicationController

  # A user whose sole company was destroyed needs to be able to create one
  skip_before_filter :require_current_company
  
  def index
    render(json: current_user.decorate.companies_as_json)
  end
  
  def new
    @company = Company.new 
    @user = current_user || @company.users.build
  end

  def create
    @user = User.where(email: params[:user][:email]).first || User.new(params[:user])
    @company = Company.new(params[:company])

    Company.transaction do
      if @company.save and @user.save 
        @company.users << @user
        @user.current_company = @company if @user.current_company.nil?
      else
        raise ActiveRecord::Rollback
      end
    end

    if @company.persisted?
      @user.administrates!(@company)
      redirect_to root_url, notice: "Company was successfully created"
    else
      flash[:errors] = @company.errors.full_messages
      render action: :new
    end
  end
end
