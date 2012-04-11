class Api::CompaniesController < ApplicationController
  skip_before_filter :require_current_user
  respond_to :json
  
  def index
    if params[:secret].eql? StaffPlan::Application.config.secret_api_token 
      respond_with Company.all_with_users_and_projects 
    else 
      render json: {}, status: :forbidden and return 
    end
  end

end
