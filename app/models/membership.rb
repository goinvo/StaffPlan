class Membership < ActiveRecord::Base

  attr_accessible :company_id, :salary, :rate, :full_time_equivalent, :payment_frequency #, :user_id
  attr_accessible :weekly_allocation, :employment_status, :disabled, :archived #, :permissions
  
  belongs_to :user
  belongs_to :company

  # ASSOC = {
  #   :admin => :administrates!,
  #   :financials => :handles_financials_of!
  # } 

  # bitmask :roles, :as => [:admin, :employee, :contractor, :financials], :null => false
  bitmask :permissions, :as => [:admin, :financials], :null => false

  # def permissions=(perms)
  #   unless perms.nil?
  #     perms.each do |perm|
  #       self.permissions << perm.to_sym 
  #     end
  #     (Membership.values_for_permissions - perms.map(&:to_sym)).each do |perm|
  #       permissions.delete perm
  #       save
  #     end
  #   else
  #     Membership.values_for_permissions.each do |perm|
  #       permissions.delete perm
  #     end
  #     save
  #   end
  # end

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
