class AddCompanyIdOnClients < ActiveRecord::Migration
  def up
    add_column :clients, :company_id, :integer
  end

  def down
    remove_column :clients, :company_id
  end
end
