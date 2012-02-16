class CreateCompaniesUsersJoinTable < ActiveRecord::Migration
  def change 
    create_table :companies_users, :id => false do |t|
      t.integer :company_id
      t.integer :user_id
    end
    add_index :companies_users, [:company_id, :user_id]
  end
end
