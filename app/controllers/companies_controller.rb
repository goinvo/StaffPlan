class CompaniesController < ApplicationController
  def new
    @company = Company.new 
    @user = @company.users.build
  end

  def create
    @user = User.where(email: params[:user][:email]).first || User.new(params[:user])
    @company = Company.new(params[:company])
    if @user.save
      @company.users << @user
      if @company.save
        # That notice thing doesn't really work
        redirect_to root_url, notice: "Company was successfully created" and return
      else
        flash[:errors] = @company.errors.full_messages
        render action: :new
      end
    else
      flash[:errors] = @user.errors.full_messages
      render action: :new 
    end
  end

end
