class Users::Projects::WorkWeeksController < ApplicationController
  include StaffPlan::SharedFinderMethods
  
  before_filter :find_target_user, :find_project
  before_filter :find_work_week, :only => :update
  
  def create
    @work_week = WorkWeek.new(whitelist_attributes)
    if @work_week.save
      render_json_ok
    else
      render_json_fail
    end
  rescue ActiveRecord::RecordNotUnique => e
    render_json_ok
  end
  
  def update
    if @work_week.update_attributes(whitelist_attributes)
      render_json_ok
    else
      render_json_fail
    end
    
  end
  
  private
  
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
             year: params[:year],
            actual_hours: params[:actual_hours],
            estimated_hours: params[:estimated_hours] }
    
    if action_name == "create"
      base.merge!(
        project_id: @project.id,
        user_id: @target_user.id
      )
    end
    
    base
  end
end
