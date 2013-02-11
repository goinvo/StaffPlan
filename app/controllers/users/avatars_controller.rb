class Users::AvatarsController < ApplicationController
  skip_before_filter :require_current_user
  skip_before_filter :require_current_company
  # GET the path to the image file
  def show
    
  end

  # POST a new image file to associate it to the user
  def update
    # Files over 20KB are handled over as TempFile objects in the request body and respond to :path
    # and can simply be moved to the uploads directory
    respond_to do |format|
      @user = User.where(:id => params[:user_id]).first
      format.json do 
        if @user.update_attributes(:avatar => request.body) 
          render :json => { :status => :ok, :src => @user.avatar.url(:thumb) }
        else
          render :json => { :status => :unprocessable_entity }
        end
      end
    end
  end
end
