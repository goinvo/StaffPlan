# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_preference, :class => 'UserPreferences' do
    email_reminder false
    user_id 1
  end
end
