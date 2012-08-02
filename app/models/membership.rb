class Membership < ActiveRecord::Base

  attr_accessible :company_id, :salary, :rate, :full_time_equivalent, :payment_frequency
  attr_accessible :weekly_allocation, :employment_status, :disabled, :archived
  
  belongs_to :user
  belongs_to :company

  # validates :weekly_allocation, :payment_frequency, :rate, :presence => true, :if => Proc.new { |m| m.?(:contractor) }
  # validates :salary, :full_time_equivalent, :presence => true, :if => Proc.new { |m| m.roles?(:employee) }

  bitmask :roles, :as => [:admin, :employee, :contractor, :financials], :null => false
  bitmask :permissions, :as => [:admin, :financials], :null => false

  before_save do |record|
    if record.disabled?
      u = record.user
      # We're disabling that user for the very last company he's attached to
      if u.selectable_companies.count == 1 and u.current_company == record.company
        u.current_company = nil  
      else
        u.current_company = (u.selectable_companies - [u.current_company]).first
      end
      u.save
    end
  end
end
