class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  before_save do |record|
    if record.disabled?
      u = record.user
      # We're disabling that user for the very last company he's attached to
      if u.selectable_companies.count == 1 and u.current_company == company
        u.current_company = nil  
      else
        u.current_company = (u.selectable_companies - [u.current_company]).first
      end
      u.save
    end
  end
end
