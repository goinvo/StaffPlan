class Assignment < ActiveRecord::Base
  has_many :work_weeks, dependent: :destroy
  belongs_to :project
  belongs_to :user
end
