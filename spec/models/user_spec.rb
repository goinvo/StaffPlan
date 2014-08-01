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

  describe "user roles" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company)
      @company.users << @user
      @user.current_company_id = @company.id
      @user.save
    end

    it "should assign the employment status of full-time employee to a default user" do
      m = @user.memberships.where(company_id: @company.id).first
      m.employment_status.should eq("fte")
    end

    it "should provide a convenience methods to assign employment status" do
      [[:interning_at!, "intern"], [:employee_of!, "fte"], [:contractor_for!, "contractor"]].each do |msg, role|
        @user.send(msg, @company)
        m = @user.memberships.where(company_id: @company.id).first
        m.employment_status.should eq(role)
      end
    end

    it "should provide convenience methods to assign permissions" do
      {:administrates! => :admin, :handles_financials_of! => :financials}.each do |msg, perm|
        @user.send(msg, @company)
        m = @user.memberships.where(company_id: @company.id).first
        m.permissions?(perm).should be_true
      end
    end

    it "should provide conveniences to test the permissions of users" do
      m = @user.memberships.where(company_id: @company.id).first
      @user.update_permissions(nil, @company) # The user has NO permissions for that company
      m.permissions << :admin
      m.save
      @user.administrates?(@company).should be_true
      @user.handles_financials_of?(@company).should be_false
      m.permissions.delete :admin
      m.save
      @user.administrates?(@company).should be_false
      m.permissions << :financials
      m.save
      @user.handles_financials_of?(@company).should be_true
    end
  end

  describe '#current_company' do
    it "should return false if the company isn't associated with the user"
    it "should set current_company_id to the company's id"
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
