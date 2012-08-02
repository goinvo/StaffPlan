class ChangeCostHandlingOnProjectsToPeriodicityAndCost < ActiveRecord::Migration
  def up
    remove_column :projects, :total_cost
    remove_column :projects, :monthly_cost

    add_column :projects, :cost, :decimal, :precision => 12, :scale => 2, :null => false, :default => 0
    add_column :projects, :payment_frequency, :string, :null => false, :default => "total"
  end

  def down
  end
end
