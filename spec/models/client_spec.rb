require 'spec_helper'

describe Client do
  describe 'validations' do
    it "should not be valid? for new instances" do
      Client.new.valid?.should be_falsy
    end
    
    it "should be valid? with valid attributes" do
      Client.new(
        name: Faker::Company.name
      ).valid?.should be_truthy
    end
  end
end
