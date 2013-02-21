class AddDisplayDatesToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :display_dates, :boolean, :null => false, :default => false
  end
end
