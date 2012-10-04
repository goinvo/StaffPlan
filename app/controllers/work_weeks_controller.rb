class WorkWeeksController < ApplicationController
  
  respond_to :json

  def create
    @assignment = Assignment.where(id: params[:assignment_id]).first
    if @work_week = @assignment.work_weeks.create(params[:work_week])
      respond_with @work_week and return
    else
      respond_with {:status => :unprocessable_entity } and return
    end
  end

  def update
    @work_week = WorkWeek.where(id: params[:id])
    if @work_week.update_attributes params[:work_week]
      respond_with @work_week and return
    else
      respond_with {:status => :unprocessable_entity } and return
    end
  end

  def destroy
  end

  # TODO: We should add some whitelisting of attributes right here

end
