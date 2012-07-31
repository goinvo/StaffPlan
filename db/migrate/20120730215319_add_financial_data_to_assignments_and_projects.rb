class AddFinancialDataToAssignmentsAndProjects < ActiveRecord::Migration
  def change
    # Projects have either a fixed total cost or a monthly cost
    add_column :projects, :total_cost, :integer, :null => false, :default => 0
    add_column :projects, :monthly_cost, :integer, :null => false, :default => 0

    add_column :memberships, :salary, :decimal, :precision => 12, :scale => 2
    add_column :memberships, :rate, :decimal, :precision => 10, :scale => 2
    add_column :memberships, :full_time_equivalent, :precision => 12, :scale => 2
    add_column :memberships, :payment_frequency, :string
    add_column :memberships, :weekly_allocation, :integer
  end
end
