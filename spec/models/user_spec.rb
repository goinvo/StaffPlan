require 'spec_helper'

describe User do
  describe 'validations' do
    it "should not be valid? for new instances" do
      User.new.valid?.should be_false
    end
    
    it "should be valid? with valid attributes" do
      User.new(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password'
      ).valid?.should be_true
    end
    
    it "should validate the email format" do
      User.create(email: "thisisnotanemailaddress").errors[:email].should_not be_empty
    end
  end
end
