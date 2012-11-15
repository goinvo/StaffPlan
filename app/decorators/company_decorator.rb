class CompanyDecorator < Draper::Base
  decorates :company

  def clients_as_json
    company_projects = model.projects.group_by(&:client_id)
    
    Jbuilder.encode do |json|
      json.array! model.clients do |json, client|
      json.(client, :id, :name, :description, :active)
        json.projects company_projects[client.id]
      end
    end
  end
  
  def assignments_as_json
    
    assignments = Assignment.includes(:work_weeks).where(
      :user_id => self.users.map(&:id), 
      :project_id => self.projects.map(&:id)
    )

    Jbuilder.encode do |json|
      json.array! assignments do |json, assignment|
        json.(assignment, :id, :user_id, :project_id, :proposed)
        json.client_id assignment.project.client_id
        json.work_weeks assignment.work_weeks do |json, work_week|
          json.(work_week, :id, :actual_hours, :estimated_hours, :beginning_of_week) 
          json.proposed assignment.proposed 
        end
      end
    end
  end

  def self_as_json
    Jbuilder.encode do |json|
      json.(self, :id, :name)
    end
  end

  def projects_as_json
    Jbuilder.encode do |json|
      json.array!(model.projects) do |json, project|
        json.(project, :id, :client_id, :name, :active, :cost, :payment_frequency, :company_id)
      end
    end
  end
  
  def users_json
    Jbuilder.encode do |json|
      company_memberships = Membership.includes(:user).where(
        :company_id => model.id
      ) 
      json.array!(company_memberships) do |json, membership|
        user = membership.user.decorate
        json.(user, :id, :first_name, :last_name, :full_name, :email, :gravatar, :current_company_id)
        json.membership membership 
      end
    end
  end
end
