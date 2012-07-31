require 'active_support/concern'

module StaffPlan::UserRoles
  extend ActiveSupport::Concern

  included do
    # Code to be executed upon inclusion
  end

  ASSOC = {
    :admin => :administrates!,
    :employee => :employee_of!,
    :contractor => :contractor_for!,
    :financials => :handles_financials_of!
  } 

  def update_roles(roles, company)
    # NOTE: Since checkbox don't play well with unchecked values we assign what we have
    # and remove what's not present
    unless roles.nil?
      roles.each do |role|
        send(ASSOC[role.to_sym], company)
      end

      m = memberships.where(:company_id => company.id).first
      (Membership.values_for_roles - roles.map(&:to_sym)).each do |role|
        m.roles.delete role
        m.save
      end
    end
  end

  def administrates?(company)
    memberships.where(:company_id => company.id).first.roles? :admin
  end

  def employee_of?(company)
    memberships.where(:company_id => company.id).first.roles? :employee
  end

  def contractor_for?(company)
    memberships.where(:company_id => company.id).first.roles? :contractor
  end

  # Admins should be able to see financial information too
  def handles_financials_of?(company)
    m = memberships.where(:company_id => company.id).first
    [:financials, :admin].any? do |r|
      m.roles?(r)
    end
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

  def handles_financials_of!(company)
    m = memberships.where(:company_id => company.id).first
    m.roles << :financials
    m.save
  end

end
