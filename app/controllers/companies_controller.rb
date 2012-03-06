class CompaniesController < ApplicationController
  def new
    @company = Company.new 
    @user = @company.users.build
  end

  def create
    @company = Company.new(params[:company])
    @user = User.where(email: params[:user][:email]).first
    @user ||= User.create(params[:user])
    @company.users << @user
    if @company.save!
      redirect_to root_url, notice: "Company was successfully created"
    else
      redirect_to :back, notice: "oops, something went wrong"
    end
  end
end
