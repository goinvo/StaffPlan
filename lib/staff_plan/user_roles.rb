require 'active_support/concern'

module StaffPlan::UserRoles
  extend ActiveSupport::Concern

  included do
    # Code to be executed upon inclusion
  end

  ASSOC = {
    :admin => :administrates!,
    :financials => :handles_financials_of!
  } 

  def update_permissions(perms, company)
    m = memberships.where(:company_id => company.id).first
    # NOTE: Since checkbox don't play well with unchecked values we assign what we have
    # and remove what's not present
    unless perms.nil?
      perms.each do |perm|
        send(ASSOC[perm.to_sym], company)
      end

      (Membership.values_for_permissions - perms.map(&:to_sym)).each do |perm|
        m.permissions.delete perm
        m.save
      end
    else
      Membership.values_for_permissions.each do |perm|
        m.permissions.delete perm
      end
      m.save
    end
  end

  # PERMISSIONS
  def administrates?(company)
    memberships.where(:company_id => company.id).first.permissions? :admin
  end

  def handles_financials_of?(company)
    memberships.where(:company_id => company.id).first.permissions? :financials
  end


  # SALARY / EMPLOYMENT STATUS
  def employee_of?(company)
    memberships.where(:company_id => company.id).first.employment_status == "fte"
  end

  def contractor_for?(company)
    memberships.where(:company_id => company.id).first.employment_status == "contractor"
  end

  def interning_at?(company)
    memberships.where(:company_id => company.id).first.employment_status == "intern"
  end

  def administrates!(company)
    m = memberships.where(:company_id => company.id).first
    m.permissions << :admin
    m.save
  end

  def handles_financials_of!(company)
    m = memberships.where(:company_id => company.id).first
    m.permissions << :financials
    m.save
  end

  def employee_of!(company)
    m = memberships.where(:company_id => company.id).first
    m.employment_status = "fte"
    m.save
  end

  def contractor_for!(company)
    m = memberships.where(:company_id => company.id).first
    m.employment_status = "contractor"
    m.save
  end

  def interning_at!(company)
    m = memberships.where(:company_id => company.id).first
    m.employment_status = "intern"
    m.save
  end

end
