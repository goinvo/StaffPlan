require 'spec_helper'

describe Project do
  describe 'validations' do
    it "should not be valid? for new instances" do
      Project.new.valid?.should be_false
    end
    
    it "should be valid? with valid attributes" do
      project = Project.new(name: Faker::Company.bs)
      project.client = FactoryGirl.create(:client)
      project.valid?.should be_true
    end
  end
  
  describe "#check_cost" do
    it "should do nothing if the cost is not nil" do
      project = FactoryGirl.build(:project)
      project.cost = cost = 100.0
      
      lambda {
        project.save!
      }.should_not raise_error
      
      project.cost.should eq(cost)
    end
    
    it "should set cost to 0.0 if cost is nil" do
      project = FactoryGirl.build(:project)
      project.cost = nil
      
      lambda {
        project.save!
      }.should_not raise_error
      
      project.cost.should eq(0.0)
    end
    
    it "should set cost to 0.0 if cost is an empty string" do
      project = FactoryGirl.build(:project)
      project.cost = ""
      
      lambda {
        project.save!
      }.should_not raise_error
      
      project.cost.should eq(0.0)
    end
  end
end
