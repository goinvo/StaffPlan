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

5.times do
  Client.create(
    name: Faker::Company.name,
    description: Faker::Company.catch_phrase
  )
end

Client.all.each do |client|
  4.times do
    Project.create(
      client: client,
      name: Faker::Company.bs
    )
  end
end

all_users = User.all

Project.all.each do |project|
  project.users << all_users
end