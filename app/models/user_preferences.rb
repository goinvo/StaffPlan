class UserPreferences < ActiveRecord::Base
  attr_accessible :email_reminder, :user_id
  belongs_to :user
end
