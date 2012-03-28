class RemoveAuthenticationTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :authentication_token
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This field (authentication_token in table users) has been removed from the database"
  end
end
