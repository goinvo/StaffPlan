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

  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies another user" do
      with_versioning do
        @source = Factory(:user)
        time = @source.updated_at
        @target = Factory(:user)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Name.name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about user C" do
      with_versioning do
        @source = Factory(:user)
        source_time = @source.updated_at
        @target = Factory(:user)
        @bystander = Factory(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Name.name)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end  
end
