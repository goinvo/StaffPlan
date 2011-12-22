class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string                :name
      t.text                  :description
      t.boolean               :actve,       default: true
      t.timestamps
    end
  end
end
