class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_secure_password
  
  validates_presence_of :email, :name
  validates_presence_of :password,  :on => :create
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
end
