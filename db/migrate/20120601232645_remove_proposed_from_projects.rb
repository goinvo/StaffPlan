class RemoveProposedFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :proposed
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
