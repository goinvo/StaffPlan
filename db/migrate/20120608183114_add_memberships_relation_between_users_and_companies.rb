class AddMembershipsRelationBetweenUsersAndCompanies < ActiveRecord::Migration
  def up
    create_table :memberships do |table|
      table.integer :user_id
      table.integer :company_id
      table.boolean :disabled
      table.boolean :archived
    end
  end

  def down
    drop_table :memberships
  end
end
