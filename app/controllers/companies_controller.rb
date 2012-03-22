class CompaniesController < ApplicationController


  def new
    @company = Company.new 
    @user = @company.users.build
  end

  def create
    @user = User.where(email: params[:user][:email]).first || User.new(params[:user])
    @company = Company.new(params[:company])

    Company.transaction do
      if @company.save && @company.users << @user
        @user.current_company = @company if @user.current_company.nil?
      else
        raise ActiveRecord::Rollback
      end
    end

    if @company.persisted?
      redirect_to root_url, notice: "Company was successfully created"
    else
      flash[:errors] = @company.errors.full_messages
      render action: :new
    end
  end
end
