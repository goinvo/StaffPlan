class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :client_id, :name, :active, :cost, :payment_frequency, :company_id
end
