class UsersController < ApplicationController
  before_filter only: [:show, :edit, :update, :destroy] do |c|
    c.find_target
  end
  
  def index
    @users = current_user.current_company.users 
    
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
  end

  def edit 
    @membership = @user.memberships.where(company_id: @user.current_company_id).first
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new(params[:user])
    # FIXME: Decide once and for all whether or not we want to make that mass-assignable
    @user.current_company_id = current_user.current_company_id
    respond_to do |format|
      if @user.save_unconfirmed_user
        RegistrationMailer.add_staff_notification(@user, Company.find(current_user.current_company_id)).deliver
        @user.send_invitation(current_user)
        format.html { redirect_to @user, notice: "Invitation successfully sent to #{@user.full_name}" }
        format.json { render :json => @user.attributes.merge({:gravatar => UserDecorator.decorate(@user).gravatar}), status: :created}
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :notice => "Successfully updated user" }
        format.json { render :json => @user, :status => :accepted }
      else
        if @user.errors.empty?
          @user.assign_attributes(params[:user])
          @user.save(validate: false)
          
          format.html { redirect_to @user, :notice => "Successfully updated user" }
          format.json { render :json => @user, :status => :accepted }
        else
          format.html { render action: "edit" }
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
end
