if Rails.env == "production" || Rails.env == "staging"
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => 'apikey',
    :password       => ENV['SENDGRID_API_KEY'],
    :domain         => 'staffplan.com'
  }
  ActionMailer::Base.delivery_method = :smtp
end
