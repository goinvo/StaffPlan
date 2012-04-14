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

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.current_company_id = current_user.current_company_id
    respond_to do |format|
      if @user.save_unconfirmed_user
        current_user.current_company.users << @user
        @user.send_invitation(current_user)
        format.html { redirect_to @user, notice: "Invitation successfully sent to #{@user.full_name}" }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if new_current_company_id = params[:user].present? ? params[:user].delete(:current_company_id) : nil
        company = current_user.companies.find_by_id(new_current_company_id)
        redirect_to :back and return if company.nil?
        @user.current_company_id = company.id
        @user.save
        redirect_to :back and return
      end
      
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: "User was successfully updated" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
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
