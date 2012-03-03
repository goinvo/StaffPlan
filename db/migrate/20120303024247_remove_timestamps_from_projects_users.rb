class RemoveTimestampsFromProjectsUsers < ActiveRecord::Migration
  def up
    remove_column(:projects_users, :created_at, :updated_at)
  end

  def down
  end
end
