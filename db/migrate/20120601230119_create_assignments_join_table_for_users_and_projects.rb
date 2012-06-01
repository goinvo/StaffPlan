class CreateAssignmentsJoinTableForUsersAndProjects < ActiveRecord::Migration
  def up
    # This join table will be used to store association information between users and projects
    create_table :assignments do |table|
      table.integer :user_id
      table.integer :project_id
      # Is the user providing proposals or actuals for that project?
      table.boolean :proposed, :null => false, :default => false 
    end

    add_index :assignments, [:project_id, :user_id], :unique => true

    # Migrating the data over from the previous join table (projects_users)
    pu = ActiveRecord::Base.connection.execute("SELECT * FROM projects_users")

    Assignment.transaction do
      pu.each do |assoc|
        Assignment.find_or_create_by_user_id_and_project_id assoc 
      end
    end
  end

  def down
    drop_table :assignments
  end

end
