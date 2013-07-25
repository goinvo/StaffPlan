class AssignmentsController < ApplicationController
  
  respond_to :json, :html

  def create
    if params[:user_id].present?
      @target_user = current_user.current_company.users.find(params[:user_id])
      
      if @assignment = @target_user.assignments.where(project_id: params[:project_id]).first
        # unarchive if they've previously archived and are re-adding it.
        @assignment.assign_attributes(archived: false)
      else
        @assignment = @target_user.assignments.build(params[:assignment])
      end
    else
      # TBD assignment
      project = current_user.current_company.projects.find(params[:project_id])
      
      if project.present?
        @assignment = project.assignments.build(params[:assignment])
      else
        render(json: {status: "fail"}) and return
      end
    end
    
    @assignment.save
    
    respond_with(@assignment)
  end

  def update
    # The proposed and archived fields are the ONLY ones we can update
    @assignment = current_user.current_company.assignments.find(params[:id])
    @assignment.update_attributes(params[:assignment])
    respond_with(@assignment)
  end

  def destroy
    @assignment = current_user.current_company.assignments.find_by_id(params[:id])
    
    if @assignment.blank?
      @assignment = Assignment.find(params[:id])
      # special case for TBD for now
      @assignment = nil if @assignment.user_id.present? || @assignment.project.company != current_user.current_company
    end
    
    @assignment.try(:destroy)
    render(:json => { :status => :ok })
  end
end
