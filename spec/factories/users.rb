# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email)            { |n| "testy-#{n}@example.com" }
    password                    "password"
    password_confirmation       "password"
    sequence(:first_name)       { |n| "First#{n}" }
    sequence(:last_name)        { |n| "Last#{n}" }
  end
end
