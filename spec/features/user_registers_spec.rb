require 'spec_helper'

feature 'Customer admin invites user to join customer' do
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:email) { Faker::Internet.free_email }

  scenario 'New user registers and confirms their email address', :js do
    
    clear_emails
    
    visit root_path
    
    within('.registration') do
      click_link 'create one now!'
    end
    
    within('#new_registration') do
      fill_in('user[first_name]', with: first_name)
      fill_in('user[last_name]', with: last_name)
      fill_in('user[email]', with: email)
      fill_in('user[password]', with: Faker::Internet.password)
      fill_in('company[name]', with: Faker::Company.name)
      click_button 'Create account'
    end
    
    expect(page).to have_content "confirmation"
    
    open_email(email)
    current_email.click_link('Click here to confirm')
    
    expect(page).to have_content(first_name)
    expect(page).to have_content(last_name)
  end
  
  scenario "Existing user logs in", :js
  scenario "Existing user logs out", :js
  scenario "Existing user resets password", :js
end
