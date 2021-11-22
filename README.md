      _________ __          _____  _______________.__
     /   _____//  |______ _/ ____\/ ____\______   \  | _____    ____  
     \_____  \\   __\__  \\   __\\   __\ |     ___/  | \__  \  /    \
     /        \|  |  / __ \|  |   |  |   |    |   |  |__/ __ \|   |  \
    /_______  /|__| (____  /__|   |__|   |____|   |____(____  /___|  /
            \/           \/                                 \/     \/

## Setup Instructions

##### Note: This guide is assuming you are running OSX Lion

### dependencies
  1. Install homebrew: https://github.com/mxcl/homebrew/wiki/installation
  1. `brew install postgresql git rbenv ruby-build`
  
### postgres
  1. TODO: customizations still needed?

### ruby
  1. rbenv install 2.1.2
    
### app
  1. Clone the repo from github, `git clone git@github.com:rescuedcode/StaffPlan.git`
  1. cd to the app and `bundle`
  1. `rake db:create`
  1. bootstrap local database using prod data: `heroku pg:transfer --to postgres://localhost/staff_plan_development --app staffplan`
    1. (You may heroku credentials for this. You'll also need to be given permission explicitly.)
  1. run the app!: `bundle exec rails s`

### For guidance to incorporate StaffPlan into your organization, contact us at hello@goinvo.com. ###
