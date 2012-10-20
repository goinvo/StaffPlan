class AssignmentsController < ApplicationController
  
  respond_to :json

  def create
    @assignment = Assignment.new params[:assignment]
    if @assignment.save
      respond_with @assignment and return
    else
      render :json => {:status => :unprocessable_entity }
    end
  end

  def update
    # The proposed field is the ONLY one we can update
    @assignment = Assignment.where(:id => params[:id]).first
    if @assignment.update_attributes params[:assignment].slice(:proposed)
      respond_with @assignment and return
    else
      render :json => {:status => :unprocessable_entity }
    end
  end

  def destroy
    @assignment = Assignment.where(id: params[:id]).first
    @assignment.destroy
    render :json => { :status => :ok }  
  end
  
  private
  
  def find_or_create_company_project_by_name
    @project = if current_user.current_company.projects.exists?(name: params["project_name"])
      current_user.current_company.projects.where(name: params["project_name"]).first
    else
      # create project, first find client
      client = find_or_create_company_client_by_name
      current_user.current_company.projects.create!(
        name: params["project_name"],
        client: client
      )
    end
    
  rescue => e
    # TODO: catch this case with backbone validations?
    Rails.logger.info("#{e.message}\n#{e.backtrace.join("\n")}")
    render :json => {:status => :unprocessable_entity }
  end
  
  def find_or_create_company_client_by_name
    client = if current_user.current_company.clients.exists?(id: params[:client_id])
      current_user.current_company.clients.find(params[:client_id])
    else
      current_user.current_company.clients.create!(
        name: params[:client_name] || "random-#{Time.now.to_i}"
      )
    end
  rescue => e
    # TODO: catch this case with backbone validations?
    Rails.logger.info("#{e.message}\n#{e.backtrace.join("\n")}")
    render :json => {:status => :unprocessable_entity }
  end

end
