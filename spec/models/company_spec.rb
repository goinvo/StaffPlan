require 'spec_helper'

describe Company do
  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies a company" do
      with_versioning do
        @source = Factory(:user)
        time = @source.updated_at
        @target = Factory(:company)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about a company" do
      with_versioning do
        @source = Factory(:user)
        source_time = @source.updated_at
        @target = Factory(:company)
        @bystander = Factory(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end
end
