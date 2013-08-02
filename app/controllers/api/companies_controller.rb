class Api::CompaniesController < ApplicationController
  skip_before_filter :require_current_user, :require_current_company
  respond_to :json
  
  def show
    respond_with Company.all_with_users_and_projects   
  end
  
  def index
    respond_with Company.all_with_users_and_projects 
  end

end
