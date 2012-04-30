# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :work_week do
    user      { FactoryGirl.create(:user) }
    project   { FactoryGirl.create(:project) }
  end
end
