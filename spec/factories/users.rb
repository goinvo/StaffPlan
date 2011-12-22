# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email                 "test@example.com"
    password              "password"
    password_confirmation "password"
    name                  "Testy"
  end
end
