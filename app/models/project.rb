class Project < ActiveRecord::Base
  include StaffPlan::AuditMethods
  has_paper_trail

  attr_accessible :name, :active, :payment_frequency, :cost

  belongs_to  :client
  belongs_to  :company

  has_many :assignments, :dependent => :destroy
  has_many :work_weeks, through: :assignments
  has_many :users, through: :assignments

  after_update :update_originator_timestamp

  validates_presence_of :name, :client
  validates_uniqueness_of :name, case_sensitive: false, scope: :client_id

  default_scope(order: "client_id ASC, name ASC")

  def proposed_for_user?(user)
    assignments.where(user_id: user.id).first.try(:proposed?) || false
  end

end
