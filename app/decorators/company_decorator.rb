class CompanyDecorator < Draper::Base
  decorates :company

  def clients_as_json
    # Cheap and grouped by client id
    company_projects = model.projects.group_by(&:client_id)
    
    Jbuilder.encode do |json|
      json.array! model.clients do |json, client|
      json.(client, :id, :name, :active)
        # We've got it in the hash, fetch it
        json.projects company_projects[client.id]
      end
    end
  end
  
  def projects_as_json
    Jbuilder.encode do |json|
      json.array!(model.projects) do |json, project|
        json.(project, :client_id, :name, :active, :proposed, :cost, :payment_frequency)
      end
    end
  end
end
