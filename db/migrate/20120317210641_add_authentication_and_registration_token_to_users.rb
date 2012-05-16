class AddAuthenticationAndRegistrationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :registration_token, :string
    add_column :users, :registration_token_sent_at, :datetime
  end
end
