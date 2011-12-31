class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string                :name
      t.text                  :description
      t.boolean               :active,       default: true
      t.timestamps
    end
  end
end
