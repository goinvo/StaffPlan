class UsersController < ApplicationController
  before_filter only: [:show, :edit, :update, :destroy] do |c|
    c.find_target
  end
  
  # GET /users
  # GET /users.json
  def index
    @users = current_user.current_company.users 
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  def edit 
    @membership = @user.memberships.where(company_id: @user.current_company_id).first
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @membership = @user.memberships.build(company_id: current_user.current_company_id)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    membership = params[:user].delete :membership
    @user = User.new(params[:user])
    @user.current_company_id = current_user.current_company_id
    respond_to do |format|
      if @user.save_unconfirmed_user
        current_user.current_company.users << @user
        @user.memberships.first.update_attributes membership.except(:permissions)
        @user.send_invitation(current_user)
        @user.update_permissions(membership[:permissions], current_user.current_company)
        format.html { redirect_to @user, notice: "Invitation successfully sent to #{@user.full_name}" }
        format.json { render json: @user, status: :created}
      else
        format.html { @membership = @user.memberships.build(company_id: @user.current_company_id); render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    if [:password, :password_confirmation].all? { |m| params[:user][m].blank? }
      params[:user].delete_if {|k,v| k =~ /password/ }
    end
    respond_to do |format|
      if new_current_company_id = params[:user].present? ? params[:user].delete(:current_company_id) : nil
        company = current_user.companies.find_by_id(new_current_company_id)
        redirect_to :back and return if company.nil?
        @user.current_company_id = company.id
        @user.save
        redirect_to :back and return
      end
      if @user.attributes = params[:user].except(:membership) and @user.save_unconfirmed_user
        @user.memberships.where(company_id: current_user.current_company_id).first.update_attributes(params[:user][:membership])
        @user.update_permissions(params[:permissions], current_user.current_company)
        format.html { redirect_to @user, notice: "User was successfully updated" }
        format.json { head :ok }
      else
        format.html { @membership = @user.memberships.where(company_id: @user.current_company_id).first; render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
end
