class WorkWeeksController < ApplicationController
  
  respond_to :json

  def create
    @assignment = Assignment.where(id: params[:assignment_id]).first
    @work_week = @assignment.work_weeks.build(params[:work_week])
    if @work_week.save
      respond_with(@work_week, location: nil) and return
    else
      render :json => { :status => :unprocessable_entity } and return
    end
  end

  def update
    @work_week = WorkWeek.where(id: params[:id]).first
    if @work_week.update_attributes(params[:work_week])
      respond_with @work_week and return
    else
      render :json => {:status => :unprocessable_entity } and return
    end
  end

  def destroy
  end

  # TODO: We should add some whitelisting of attributes right here

end
