# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :work_week do
    user      { Factory(:user) }
    project   { Factory(:project) }
  end
end
