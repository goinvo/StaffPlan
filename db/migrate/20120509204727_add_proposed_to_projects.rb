class AddProposedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :proposed, :boolean, null: false, default: false
  end
end
