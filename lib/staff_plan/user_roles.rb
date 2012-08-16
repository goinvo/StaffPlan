require 'active_support/concern'

module StaffPlan::UserRoles
  extend ActiveSupport::Concern

  def administrates?(company)
    memberships.where(:company_id => company.id).first.roles? :admin
  end

  def employee_of?(company)
    memberships.where(:company_id => company.id).first.roles? :employee
  end

  def contractor_for?(company)
    memberships.where(:company_id => company.id).first.roles? :contractor
  end

  def administrates!(company)
    m = memberships.where(:company_id => company.id).first
    m.roles << :admin
    m.save
  end
  
  def employee_of!(company)
    m = memberships.where(:company_id => company.id).first
    m.roles << :employee
    m.save
  end
  
  def contractor_for!(company)
    m = memberships.where(:company_id => company.id).first
    m.roles << :contractor
    m.save
  end

end
