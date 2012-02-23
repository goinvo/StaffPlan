class Company < ActiveRecord::Base

  has_and_belongs_to_many :users, uniq: true
  has_many :projects
  has_many :clients

end
