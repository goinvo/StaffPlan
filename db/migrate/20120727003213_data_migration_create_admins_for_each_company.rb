class DataMigrationCreateAdminsForEachCompany < ActiveRecord::Migration
  def up
    Company.all.each do |company|
      new_admin = company.users.min { |a,b| a.created_at <=> b.created_at }
      if new_admin.present?
        new_admin.administrates! company
      else
        next
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
