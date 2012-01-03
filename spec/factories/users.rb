# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "testy-#{n}@example.com" }
    password              "password"
    password_confirmation "password"
    sequence(:name)        { |n| "Testy #{n}" }
  end
end
