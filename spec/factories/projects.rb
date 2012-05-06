FactoryGirl.define do
  factory :project do
    name    { Faker::Company.bs }
    client  { FactoryGirl.create(:client) }
  end
end
