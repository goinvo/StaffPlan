class AddArchivedToAssignments < ActiveRecord::Migration
  def change
    add_column(:assignments, :archived, :boolean, null: false, default: false)
  end
end
