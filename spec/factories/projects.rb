# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name    Faker::Company.bs
    client  Factory(:client)
  end
end
