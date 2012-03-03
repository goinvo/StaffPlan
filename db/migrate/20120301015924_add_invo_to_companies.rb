class AddInvoToCompanies < ActiveRecord::Migration
  def change
    invo = Company.create!(name: "Involution Studios")
    all_users = User.all
    invo.users << all_users
    all_users.each { |u| u.update_attributes(current_company_id: invo.id) }
    Project.all.each { |p| p.update_attributes(company_id: invo.id) }
    Client.all.each { |c| c.update_attributes(company_id: invo.id) }
  end
end
