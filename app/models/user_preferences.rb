class UserPreferences < ActiveRecord::Base
  attr_accessible :email_reminder, :display_dates, :user_id
  belongs_to :user
end
