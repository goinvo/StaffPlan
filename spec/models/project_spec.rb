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
  
  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies a project" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        time = @source.updated_at
        @target = FactoryGirl.create(:project)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about a company" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        source_time = @source.updated_at
        @target = FactoryGirl.create(:project)
        @bystander = FactoryGirl.create(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @bystander.reload.updated_at.should == bystander_time
      end
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
