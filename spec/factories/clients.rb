# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client do
    name          Faker::Company.name
    description   Faker::Company.catch_phrase
  end
end
