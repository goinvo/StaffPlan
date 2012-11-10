class AssignmentsController < ApplicationController
  
  before_filter :find_target_user, only: [:create]
  
  respond_to :json

  def create
    @assignment = @target_user.assignments.build(params[:assignment])
    
    if @assignment.save
      respond_with @assignment and return
    else
      render :json => {:status => :unprocessable_entity }
    end
  end

  def update
    # The proposed field is the ONLY one we can update
    @assignment = Assignment.where(:id => params[:id]).first
    if @assignment.update_attributes params[:assignment].slice(:proposed)
      respond_with @assignment and return
    else
      render :json => {:status => :unprocessable_entity }
    end
  end

  def destroy
    @assignment = Assignment.where(id: params[:id]).first
    @assignment.destroy
    render :json => { :status => :ok }  
  end
  
  private
  
  def find_target_user
    @target_user = current_user.current_company.users.find(params[:target_user_id])
  rescue
    render(status: 404)
  end
end
