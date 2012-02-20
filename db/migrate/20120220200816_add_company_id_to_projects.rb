class AddCompanyIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :company_id, :integer
  end
end
