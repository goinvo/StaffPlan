require 'spec_helper'

describe Users::Projects::WorkWeeksController do

  before(:each) do
    @user = login_user
    @project = Factory(:project, :users => [@user])
  end

  def base_params
    {user_id: @user.id, project_id: @project.id}
  end

  describe "all actions" do
    it "should redirect if the target user can't be found" do

    end
  end

  describe '#create' do

  end

  describe '#update' do

    before(:each) do
      @work_week = Factory(:work_week, user: @user, project: @project)
    end

    it "should render the fail JSON response if update_attributes fails" do
      WorkWeek.any_instance.stubs(:update_attributes).returns(false) 
      put :update, user_id: @user.id, project_id: @project.id, id: @work_week.id, cweek: 19
      @body = JSON.parse(response.body)
      @body.class.should eq(Hash)
      @body['status'].should eq("fail")
    end

    it "should only pass whitelisted attributes to WorkWeek#update_attributes" do
      attrs = {
        user_id: @user.id, 
        project_id: @project.id, 
        id: @work_week.id, 
        cweek: 18, 
        year: "2012", 
        actual_hours: 18, 
        estimated_hours: 24, 
        bullshit_hours: 24,
        velocity: 34
      }
      # Not sure what to even test here... Shouldn't the whitelist_attributes method itself be tested instead?
    end

    it "should render the OK JSON if update_attributes passes" do
      WorkWeek.any_instance.expects(:update_attributes).with(anything).returns(true)
      put :update, user_id: @user.id, project_id: @project.id, id: @work_week.id, cweek: 19
      @body = JSON.parse(response.body)
      @body.class.should eq(Hash)
      @body['status'].should eq("ok")
    end
  end

end
