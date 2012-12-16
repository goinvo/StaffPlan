class StaffplansController < ApplicationController
  def show
  end
 
  def inactive
  end

  def index
  end
  
  def my_staffplan
    redirect_to staffplan_url(current_user)
  end
end
