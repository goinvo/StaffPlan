class StaffplansController < ApplicationController
  
  def show
    @target_user = User.where(id: params[:id]).first
    
    redirect_to root_url, error: I18n.t('controllers.staffplans.couldnt_find_user') unless @target_user.present?
    
    @target_user_json = @target_user.to_json(only: [:id, :name, :email], 
                                             include:
                                              { projects:
                                                { include:
                                                  { work_weeks: 
                                                    { only: [:id, :cweek, :year, :estimated_hours, :actual_hours] }
                                                  } 
                                                }
                                              }
                                            )
    @clients = Client.all
  end
  
  private
  
  def number_of_work_weeks
    from = Date.today.beginning_of_week
    to = Date.today.in(3.months).to_date # hard code for now
    cweeks = []
    
    while from <= to
      cweeks << {
        from.year => from.cweek
      }
      from = from.next_week
    end
    
    cweeks
  end
  helper_method :number_of_work_weeks
  
end
