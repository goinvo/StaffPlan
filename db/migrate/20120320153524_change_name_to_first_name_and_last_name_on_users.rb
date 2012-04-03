class ChangeNameToFirstNameAndLastNameOnUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    User.reset_column_information
    User.all.each do |user|
      fname, lname = *user.name.split(" ")
      user.first_name = fname
      user.last_name = lname
      user.save
    end
    remove_column :users, :name
  end

  def down
    add_column :users, :name, :string
    User.all.each do |user|
      user.name = [user.first_name, user.last_name].join(" ")
    end
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end
