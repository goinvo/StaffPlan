require 'spec_helper'

describe User do

  describe 'validations' do
    it "should not be valid? for new instances" do
      User.new.valid?.should be_false
    end

    it "should be valid? with valid attributes" do
      User.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password'
      ).valid?.should be_true
    end

    it "should validate the email format" do
      User.create(email: "thisisnotanemailaddress").errors[:email].should_not be_empty
    end

    it "should not allow the creation of a user whose email address already exists" do
      address = Faker::Internet.email
      User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: address, password: 'password')
      User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: address, password: 'other_password').errors[:email].should eq(["has already been taken"])
    end

  end

  describe '#plan_for' do
    before(:each) do
      @user = User.new(email: Faker::Internet.email, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: "23kj23k2j")
      @company = FactoryGirl.create(:company)
      @company.users << @user
      @user.current_company_id = @company.id
      @user.save

      @client = Client.new(name: Faker::Company.name, description: Faker::Lorem.sentences(2), active: true)
      @client.company_id = @company.id
      @client.save

      @project = Project.new(name: Faker::Company.name, name: Faker::Company.bs)
      @project.company_id = @company.id
      @project.client_id = @client.id
      @project.save
      
      @project_ids = @company.projects.map(&:id)
    end 

    it "should return 0 when I try to get the number of estimated hours for a new user" do
      @user.plan_for(@company.id, Date.today).should eq(0)
    end

    it "should return 0 when the user hasn't put any estimates for the future" do
      @work_week = WorkWeek.new(cweek: 2.months.ago(Date.today).cweek, year: Date.today.year, estimated_hours: 20, actual_hours: 12)
      @work_week.project_id = @project.id
      @work_week.user_id = @user.id
      @work_week.save
      @user.plan_for(@project_ids, Date.today).should eq(0)
    end

    it "should return the sum of workload estimates for the future" do
      @w1 = WorkWeek.new(cweek: 2.months.from_now(Date.today).cweek, year: Date.today.year, estimated_hours: 20, actual_hours: 12)
      @w1.project_id = @project.id

      @w2 = WorkWeek.new(cweek: 1, year: 3.years.from_now(Date.today).year, estimated_hours: 80, actual_hours: 12)
      @w2.project_id = @project.id

      @user.work_weeks << [@w1, @w2]
      @user.save
      @user.plan_for(@project_ids, Date.today).should eq(100)
    end
  end
  
  describe '#current_company' do
    it "should return false if the company isn't associated with the user"
    it "should set current_company_id to the company's id"
  end

  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies another user" do
      User.destroy_all
      with_versioning do
        @source = FactoryGirl.create(:user)
        time = @source.updated_at
        @target = FactoryGirl.create(:user)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(first_name: Faker::Name.first_name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about user C" do
      User.destroy_all
      with_versioning do
        @source = FactoryGirl.create(:user)
        source_time = @source.updated_at
        @target = FactoryGirl.create(:user)
        @bystander = FactoryGirl.create(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(first_name: Faker::Name.first_name)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end  
  
  describe '#save_unconfirmed_user' do
    it "should save the user if all required fields (except password) are present" do
      lambda {
        user = FactoryGirl.build(:user, password: nil, password_confirmation: nil)
        user.save_unconfirmed_user.should be_true
      }.should change(User, :count).by(1)
    end
    
    it "should not save if first/last name or email are missing" do
      lambda {
        user = FactoryGirl.build(:user, password: nil, password_confirmation: nil, email: nil)
        user.save_unconfirmed_user.should be_false
      }.should_not change(User, :count)
    end
  end
end
