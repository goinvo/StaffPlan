class AddMembershipsRelationBetweenUsersAndCompanies < ActiveRecord::Migration
  def up
    create_table :memberships do |table|
      table.integer :user_id
      table.integer :company_id
      table.boolean :disabled, :null => false, :default => false
      table.boolean :archived, :null => false, :default => false
    end

    add_index :memberships, [:company_id, :user_id], :unique => true
  end

  def down
    drop_table :memberships
  end
end
