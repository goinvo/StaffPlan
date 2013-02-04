class Api::PresenceController < ApplicationController 

  def ping
    respond_to do |format|
      @response = session[:user_id].present? ? :ok : :forbidden
      format.json do 
        render :json => { :status => @response }.to_json 
      end
    end
  end

end
