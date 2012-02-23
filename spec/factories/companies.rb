# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    name  Faker::Company.bs 
  end
end
