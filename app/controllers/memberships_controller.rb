class MembershipsController < ApplicationController

  def create
    membership_params = params[:membership]
    
    unless params[:membership].has_key?(:company_id)
      membership_params.merge!(company_id: params[:company_id])
    end
    
    @membership = Membership.new(membership_params)
    
    if @membership.save
      render :json => @membership, :status => :ok
    else
      render :json => @membership.errors, :status => :unprocessable_entity
    end
  end

  def update
    @membership = Membership.where(id: params[:id]).first
    
    params[:membership].merge!(archived: (params[:membership][:archived] ? 1 : 0)) if params[:membership][:archived]
    params[:membership].merge!(disabled: (params[:membership][:disabled] ? 1 : 0)) if params[:membership][:disabled]
    
    if @membership.update_attributes(params[:membership])
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
