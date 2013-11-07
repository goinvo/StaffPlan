# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment do
    user        { FactoryGirl.create(:user) }
    project     { FactoryGirl.create(:project) }
  end
end
