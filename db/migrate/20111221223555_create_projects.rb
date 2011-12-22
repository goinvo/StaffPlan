class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.belongs_to          :client
      t.string              :name
      t.boolean             :active,      default: true
      t.timestamps
    end
  end
end
