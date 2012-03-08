require 'spec_helper'

describe Project do
  describe 'validations' do
    it "should not be valid? for new instances" do
      Project.new.valid?.should be_false
    end
    
    it "should be valid? with valid attributes" do
      project = Project.new(name: Faker::Company.bs)
      project.client = Factory(:client)
      project.valid?.should be_true
    end
  end
end
