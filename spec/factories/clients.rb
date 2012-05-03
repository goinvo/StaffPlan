# Read about factories at http://github.com/thoughtbot/factory_girl
f = Fiber.new do
  x = 1
  loop do
    Fiber.yield x
    x += 1
  end
end
FactoryGirl.define do
  factory :client do
    name          { Faker::Company.name + f.resume.to_s } 
    description   { Faker::Company.catch_phrase + f.resume.to_s } 
  end
end
