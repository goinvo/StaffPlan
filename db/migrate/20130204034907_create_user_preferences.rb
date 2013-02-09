class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.boolean :email_reminder
      t.integer :user_id

      t.timestamps
    end
  end
end
