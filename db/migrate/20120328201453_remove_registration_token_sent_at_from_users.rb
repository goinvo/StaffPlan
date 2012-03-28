class RemoveRegistrationTokenSentAtFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :registration_token_sent_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This field (registration_token_sent_at in table users) has been removed from the database"
  end
end
