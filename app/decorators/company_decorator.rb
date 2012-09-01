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
        json.(project, :id, :client_id, :name, :active, :proposed, :cost, :payment_frequency)
      end
    end
  end
  
  def users_json
    Jbuilder.encode do |json|
      json.array!(model.users) do |json, user|
        user = user.decorate
        user_assignments = user.assignments.for_company(model.id)
        ww = user.work_weeks.group_by(&:project_id)
    
        json.(user, :id, :full_name, :email, :gravatar)
        json.assignments user_assignments do |json, assignment|
          json.(assignment, :id, :user_id, :project_id, :proposed)
          json.client_id assignment.project.client_id
          json.work_weeks ww[assignment.project_id] do |json, work_week|
            json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
          end
        end
      end
    end
  end
end
