class RenameUsersCurrentCompanyToCurrentCompanyId < ActiveRecord::Migration
  def up
    rename_column :users, :current_company, :current_company_id
  end

  def down
    rename_column :users, :current_company_id, :current_company
  end
end
