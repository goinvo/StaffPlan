class AddRolesToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :roles, :integer, :null => false, :default => 0 
  end
end
