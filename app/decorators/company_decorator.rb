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

  def self_as_json
    Jbuilder.encode do |json|
      json.(self, :id, :name)
    end
  end
  
  def users_json
    Jbuilder.encode do |json|
      company_memberships = Membership.includes(:user, {:user => :user_preferences}).where(
        :company_id => model.id
      )
      json.array!(company_memberships) do |json, membership|
        user = membership.user.decorate
        json.(user, :id, :first_name, :last_name, :full_name, :email, :gravatar, :current_company_id)
        preferences = user.user_preferences
        if preferences.present?
          json.preferences preferences
        end
        json.membership membership
      end
    end
  end
end
