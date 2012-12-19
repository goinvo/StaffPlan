class AssignmentsController < ApplicationController
  
  respond_to :json, :html

  def create
    if params[:assignment][:user_id].present?
      @assignment = @target_user.assignments.build(params[:assignment])
    else
      @assignment = Project.where(:id => params[:assignment][:project_id]).first.assignments.build(params[:assignment])
    end

    if @assignment.save
      respond_with @assignment and return
    else
      render :json => {:status => :unprocessable_entity }
    end
  end

  def update
    # The proposed and archived fields are the ONLY ones we can update
    @assignment = Assignment.where(:id => params[:id]).first
    if @assignment.update_attributes params[:assignment].slice(:proposed, :archived)
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
    @target_user = current_user.current_company.users.find params[:user_id]
  rescue
    render(status: 404)
  end
end
