class Company < ActiveRecord::Base
  # First commit of multicompany branch
  has_and_belongs_to_many :users, uniq: true
end
