class Users::Projects::WorkWeeksController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user, :find_project
  before_filter :find_work_week, :only => :update
  
  def create
    @work_week = WorkWeek.new(whitelist_attributes)
    
    if @work_week.save
      respond_to do |format|
        format.js { render_json_ok }
        format.mobile { render_project_partial }
      end
    else
      respond_to do |format|
        format.js { render_json_fail }
        format.mobile { render_project_partial }
      end
    end
  rescue ActiveRecord::RecordNotUnique => e
    render_json_ok
  end
  
  def update
    if @work_week.update_attributes(whitelist_attributes)
      respond_to do |format|
        format.js { render_json_ok }
        format.mobile { render_project_partial }
      end
    else
      respond_to do |format|
        format.js { render_json_fail }
        format.mobile { render_project_partial }
      end
    end
  end
  
  private
  
  def render_project_partial
    @date = (params[:date].present? ? Date.parse(params[:date]) : Date.today).at_beginning_of_week
    render(partial: 'staffplans/project', locals: {project: @project, updated: true})
  end
  
  def render_json_fail
    render(:json => {
      status: "fail",
      work_week: @work_week
    })
  end
  
  def render_json_ok
    render(:json => {
      status: "ok",
      work_week: @work_week,
      clients: Client.all
    })
  end
  
  def whitelist_attributes
    base = { cweek: params[:cweek],
             year: params[:year] }
             
    base.merge!(estimated_hours: params[:estimated_hours]) if params[:estimated_hours].present?
    base.merge!(actual_hours: params[:actual_hours]) if params[:actual_hours].present?
    
    if action_name == "create"
      base.merge!(
        project_id: @project.id,
        user_id: @target_user.id
      )
    end
    
    base
  end
end
