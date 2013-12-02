class AssignmentsController < ApplicationController
  
  respond_to :json, :html
  
  def index
    @assignments = Assignment.includes(:work_weeks).where(:project_id => current_user.current_company.projects.map(&:id))
  end
  
  def create
    if params[:assignment][:user_id].present?
      @target_user = User.where(:id => params[:assignment][:user_id]).first
      
      if @target_user.assignments.where(archived: true, project_id: params[:project_id]).any?
        @assignment = @target_user.assignments.where(project_id: params[:project_id]).first
        @assignment.assign_attributes(archived: false)
      else
        # brand new user/project assignment
        @assignment = @target_user.assignments.build(params[:assignment])
      end
    else
      @assignment = Project.where(:id => params[:assignment][:project_id]).first.assignments.build(params[:assignment])
    end
    
    @assignment.save
    
    respond_with(@assignment)
  end

  def update
    # The proposed and archived fields are the ONLY ones we can update
    @assignment = Assignment.where(:id => params[:id]).first
    if @assignment.update_attributes params[:assignment]
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
end
