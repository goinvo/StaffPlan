class RemoveHabtmTables < ActiveRecord::Migration
  def up
    drop_table(:projects_users)
    drop_table(:companies_users)
  end

  def down
  end
end
