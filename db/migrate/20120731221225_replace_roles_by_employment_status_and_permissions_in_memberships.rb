class ReplaceRolesByEmploymentStatusAndPermissionsInMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :employment_status, :string, :null => false, :default => "fte"
    add_column :memberships, :permissions, :integer, :null => false, :default => 0 

    Membership.reset_column_information

    Membership.all.each do |membership|
      [:employee, :contractor].each do |role|
        (membership.employment_status = role.to_s) if membership.roles.include?(role)
      end
      [:admin, :financials].each do |role|
        (membership.permissions << role) if membership.roles.include?(role)
      end
      membership.save
    end

    remove_column :memberships, :roles
  end

  def down
    add_column :memberships, :roles, :integer, :null => false, :default => 0

    Membership.reset_column_information
  
    Membership.all.each do |membership|
      case membership.employment_status
      when "fte"
        membership.roles << :employee
      when "contractor"
        membership.roles << :contractor
      when "intern"
        membership.roles << :intern
      end

      if membership.permissions? :admin
        membership.roles << :admin
      elsif membership.permissions? :financials
        membership.roles << :financials
      end
      membership.save

      remove_column :memberships, :employment_status
      remove_column :memberships, :permissions
    end

  end
end
