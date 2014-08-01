class Project < ActiveRecord::Base
  has_paper_trail

  attr_accessible :name, :active, :payment_frequency, :cost, :client

  belongs_to  :client
  belongs_to  :company

  has_many :assignments, :dependent => :destroy
  has_many :work_weeks, through: :assignments
  has_many :users, through: :assignments
  
  before_save :check_cost
  
  validates_presence_of :name, :client
  validates_uniqueness_of :name, case_sensitive: false, scope: :client_id

  default_scope(order: "client_id ASC, name ASC")

  def proposed_for_user?(user)
    assignments.where(user_id: user.id).first.try(:proposed?) || false
  end
  
  # DB column can't be null but incoming params may pass it. If the key's present
  # AR uses the value whatever it is, even if it's "". This doesn't trigger
  # the default value of 0.0 to be set. Ignore blank values.
  def check_cost
    assign_attributes(cost: 0.0) if self.cost.blank?
  end
end
