class Api::UsersController < ApplicationController
  skip_before_filter :require_current_user, :require_current_company
  before_filter :valid_user, :only => [ :show, :stats ]
  respond_to :json
  
  def show
    render :json => @user.decorate.self_as_json
  end
  
  def index
    @user = User.all
    render :json => Jbuilder.encode { |json| 
      json.array! @user do |json,user|
        json.(user, :id, :first_name, :last_name, :email)
      end
    }
  end
  
  def stats
    render :json => Jbuilder.encode { |json|
      json.(@user, :id, :email, :first_name, :last_name)
      json.projects @user.projects do |json, project|
        json.(project, :id, :name)
        @user.assignments.each do |assignment|
          json.work_week assignment.work_weeks do |json, work_week|
            json.work_week work_week
          end
        end
      end
    }
  end
  
  private
  def valid_user
    @user = User.find_by_id(params[:id])
    if !@user 
      render :text => '', status: :not_found
    end
  end
  

end
