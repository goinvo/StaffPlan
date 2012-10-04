class AssignmentsController < ApplicationController
  
  respond_to :json

  def create
    @assignment = Assignment.new params[:assignment]
    if @assignment.save
      respond_with @assignment and return
    else
      respond_with {:status => :unprocessable_entity }
    end
  end

  def update
    @assignment = Assignment.where(id: params[:id]).first
    if @assignment.update_attributes(params[:assignment])  
      respond_with @assignment and return
    else
      respond_with {:status => :unprocessable_entity }
    end
  end

  def destroy
    @assignment = Assignment.where(id: params[:id]).first
    @assignment.destroy
    respond_with { :status => :ok }  
  end

end
