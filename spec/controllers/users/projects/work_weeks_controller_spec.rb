require 'spec_helper'

describe Users::Projects::WorkWeeksController do

  before(:each) do
    @user, @company = login_user
    @project = Factory(:project, :users => [@user], company: @company)
  end

  def base_params
    {user_id: @user.id, project_id: @project.id}
  end

  describe '#create' do
    it "should redirect if the target user can't be found" do
      # FIXME: Not really good... Ideally I'd like to stub the call to find_by_id in
      # SharedFinderMethods to return an empty array 
      post(:create, {
        user_id: "bogus", 
        project_id: @project.id, 
        cweek: Date.today.cweek, 
        year: Date.today.year, 
        format: "js"
      })

      response.should redirect_to(root_url)
    end
    context "js" do
      it "should return a JSON OK response and keep WorkWeek.count unchanged if the user tries to save a work_week that already exists" do
        parameters = base_params.merge({
          cweek: Date.today.cweek, 
          year: Date.today.year 
        }) 
        ww = Factory(:work_week, parameters) 
        lambda {post :create, parameters.merge(format: "js")}.should_not change(WorkWeek, :count) 

        @body = JSON.parse(response.body)
        @body.should be_a(Hash)
        @body['status'].should eq("ok")
      end

      it "should return the JSON OK response for a successful work_week creation" do
        post(:create, {
          user_id: @user.id, 
          project_id: @project.id, 
          cweek: Date.today.cweek, 
          year: Date.today.year, 
          format: "js"
        })
        @body = JSON.parse(response.body)
        @body.should be_a(Hash)
        @body['status'].should eq("ok")
      end
    end
  end

  describe '#update' do

    before(:each) do
      @work_week = Factory(:work_week, user: @user, project: @project)
    end

    context "format: 'js'" do
      it "should redirect if the target user can't be found" do
        # FIXME: Not really good... Ideally I'd like to stub the call to find_by_id in
        # SharedFinderMethods to return an empty array 
        put :update, {
          user_id: "bogus", 
          project_id: @project.id, 
          id: @work_week.id, 
          cweek: 19, 
          format: 'js'
        }

        response.should redirect_to(root_url)
      end
      it "should render the fail JSON response if update_attributes fails" do
        WorkWeek.any_instance.stubs(:update_attributes).returns(false) 
        put :update, {
          user_id: @user.id, 
          project_id: @project.id, 
          id: @work_week.id, 
          cweek: 19, 
          format: 'js'
        }
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
        # Not sure what to even test here... Shouldn't the whitelist_attributes 
        # method itself be tested instead?
        # No, it's a private method.  Private methods are tested indirectly 
        # by properly testing the public methods that call them.
        # For example: params = {some: "gibberish", like: "this", year: "1999", actual_hours: 9}
        # then the WorkWeek instance should only receive the 
        # last two K/V pairs in the params hash (year, actual_hours)
      end

      it "should render the OK JSON if update_attributes passes" do
        WorkWeek.any_instance.expects(:update_attributes).with(anything).returns(true)
        put :update, {
          user_id: @user.id, 
          project_id: @project.id, 
          id: @work_week.id, 
          cweek: 19, 
          format: 'js'
        }
        @body = JSON.parse(response.body)
        @body.class.should eq(Hash)
        @body['status'].should eq("ok")
      end
    end

    context "format: 'mobile'" do
      it "should render the project partial if the update fails" do
        # Error handling/messaging is TBD
        WorkWeek.any_instance.stubs(:update_attributes).returns(false) 
        put :update, {
          user_id: @user.id, 
          project_id: @project.id, 
          id: @work_week.id, 
          cweek: 19, 
          format: 'mobile'
        }
        response.should be_success
        response.should render_template("staffplans/_project")
      end

      it "should render the project partial if the update succeeds" do
        WorkWeek.any_instance.stubs(:update_attributes).returns(true)
        put :update, {
          user_id: @user.id, 
          project_id: @project.id, 
          id: @work_week.id, 
          cweek: 19, 
          format: 'mobile'
        }
        response.should be_success
        response.should render_template("staffplans/_project")
      end
    end
  end

end
