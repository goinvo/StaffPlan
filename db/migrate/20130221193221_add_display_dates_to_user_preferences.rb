class AddDisplayDatesToUserPreferences < ActiveRecord::Migration
  def change
    add_column(:user_preferences, :display_dates, :boolean, :null => false, :default => false)
    
    User.all.each do |u|
      u.create_user_preferences
    end
  end
end
