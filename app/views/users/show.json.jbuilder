json.(@user, :id, :name, :email, :gravatar)
json.projects @user.projects do |json, project|
  json.partial! project
end
