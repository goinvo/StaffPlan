User.create(
  name: "Rob Sterner",
  email: "rob@rescuedcode.com",
  password: "secret"
)

User.create(
  name: "Juhan Sonin",
  email: "juhan@goinvo.com",
  password: "secret"
)

User.create(
  name: "Christian Hogan",
  email: "christian@goinvo.com",
  password: "secret"
)

(1 + rand(5)).times do
  Client.create(
    name: Faker::Company.name,
    description: Faker::Company.catch_phrase
  )
end

Client.all.each do |client|
  (1 + rand(4)).times do
    Project.create(
      client: client,
      name: Faker::Company.bs
    )
  end
end

Company.create(
  name: Faker::Company.name
)

company = Company.first


all_users = User.all

company.users << all_users

all_users.each do |user|
  user.current_company_id = company.id
end

Project.all.each do |project|
  project.users << all_users
end
