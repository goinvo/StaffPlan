module StaffPlan::WorkWeeksControllers
  extend ActiveSupport::Concern
  include StaffPlan::SharedFinderMethods
  
  included do
    before_filter :find_target_user, :find_project
    before_filter :find_work_week, :only => :update
  end
  
  #module InstanceMethods
    def create
      @work_week = WorkWeek.new(whitelist_attributes)
      @work_week.project_id = @project.id
      @work_week.user_id = @target_user.id
    
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
        clients: current_user.current_company.clients.includes(:projects).map(&:staff_plan_json)
      })
    end
  
    def whitelist_attributes
      base = { cweek: params[:cweek],
               year: params[:year] }
             
      base.merge!(estimated_hours: params[:estimated_hours]) if params[:estimated_hours].present?
      base.merge!(actual_hours: params[:actual_hours]) if params[:actual_hours].present?
    
      base
    end
    
  #end
end
