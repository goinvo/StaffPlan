class WorkWeeksController < ApplicationController
  
  respond_to :json

  def create
    @assignment = Assignment.where(id: params[:assignment_id]).first
    @work_week = @assignment.work_weeks.build params[:work_week]
    @work_week.save
    
    respond_to do |format|
      format.json { respond_with(@work_week, location: nil) }
      format.mobile { render(nothing: true) }
    end
  end

  def update
    @work_week = WorkWeek.where(id: params[:id]).first
    @work_week.update_attributes(params[:work_week])
    
    respond_to do |format|
      format.json { respond_with @work_week }
      format.mobile do
        @date = (params[:date].present? ? Date.parse(params[:date]) : Date.commercial(@work_week.year, @work_week.cweek)).at_beginning_of_week
        render(partial: 'staffplans/assignment', locals: {assignment: @work_week.assignment, updated: true})
      end
    end
  end

  def destroy
  end

  # TODO: We should add some whitelisting of attributes right here

end
