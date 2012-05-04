class Api::CompaniesController < ApplicationController
  skip_before_filter :require_current_user, :require_current_company
  respond_to :json
  
  def index
    if params[:secret].eql?(ENV['API_SECRET'] || StaffPlan::Application.config.api_secret)
      respond_with Company.all_with_users_and_projects 
    else 
      render json: {}, status: :forbidden and return 
    end
  end

end
