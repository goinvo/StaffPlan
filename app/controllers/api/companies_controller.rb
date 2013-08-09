class Api::CompaniesController < ApplicationController
  skip_before_filter :require_current_user, :require_current_company
  before_filter :valid_company, :only => [ :show, :stats ]
  respond_to :json
  
  def show
    render :json => @company.decorate.self_as_json
  end
  
  def index
    @companies = Company.all
    render :json => Jbuilder.encode { |json| 
      json.array! @companies do |json,company|
        json.name company.name
        json.id company.id
      end
    }
  end
  
  def stats
    render :json => Jbuilder.encode { |json| 
      json.name @company.name
      json.id @company.id
      json.users @company.users do |json, user|
        json.(user, :id, :email, :first_name, :last_name)
        json.projects user.projects do |json, project|
          json.(project, :id, :name)
          user.assignments.each do |assignment|
            json.work_week assignment.work_weeks do |json, work_week|
              json.work_week work_week
            end
          end
        end
      end
    }
  end
  
  private
  def valid_company
    @company = Company.find_by_id(params[:id])
    if !@company 
      render :text => '', status: :not_found
    end
  end
  

end
