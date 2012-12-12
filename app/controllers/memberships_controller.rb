class MembershipsController < ApplicationController

  def create
    @membership = Membership.new(params[:membership])
    if @membership.save
      render :json => @membership, :status => :ok
    else
      render :json => @membership.errors, :status => :unprocessable_entity
    end
  end

  def update
    @membership = Membership.where(id: params[:id]).first
    if @membership.update_attributes params[:membership].slice(:employment_status, :salary, :full_time_equivalent, :rate, :payment_frequency, :weekly_allocation, :permissions)
      render :json => @membership, :status => :ok
    else
      render :json => @membership.errors, :status => :unprocessable_entity
    end

  end

  def destroy
    @membership = Membership.where(id: params[:id]).first
    @membership.destroy

    render :json => { :status => :ok }
  end
end
