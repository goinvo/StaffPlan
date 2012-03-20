class CompaniesController < ApplicationController

  def index
    @companies = current_user.companies
  end

  def show
    @company = current_user.companies.find_by_id(params[:id])
  end

  def new
    @company = Company.new 
    @user = @company.users.build
  end
  def edit
    @company = current_user.companies.find_by_id(params[:id])
  end

  def update
    @company = current_user.companies.find_by_id(params[:id])
    # FIXME: I made the administrator_id mass-assignable, discuss with Rob
    if @company.update_attributes(params[:company])
      redirect_to @company
    else
      render action: "edit"
    end
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

  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to my_staffplan_path, notice: "Company was succesfully detroyed" }
      format.json { head :ok }
    end
  end

end
