class AddAdministratorIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :administrator_id, :integer
  end
end
