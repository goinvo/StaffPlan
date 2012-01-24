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
    
  end
end
