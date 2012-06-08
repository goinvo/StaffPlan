class DataMigrationMoveCompaniesUsersInfoToMemberships < ActiveRecord::Migration
  def up
    cu = ActiveRecord::Base.connection.execute("SELECT * FROM companies_users")
    
    Membership.transaction do
      cu.each do |assoc|
        Membership.find_or_create_by_company_id_and_user_id assoc
      end
    end
  end

  def down
  end
end
