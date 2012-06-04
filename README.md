
      _________ __          _____  _______________.__                 
     /   _____//  |______ _/ ____\/ ____\______   \  | _____    ____  
     \_____  \\   __\__  \\   __\\   __\ |     ___/  | \__  \  /    \ 
     /        \|  |  / __ \|  |   |  |   |    |   |  |__/ __ \|   |  \
    /_______  /|__| (____  /__|   |__|   |____|   |____(____  /___|  /
            \/           \/                                 \/     \/ 

## Setup Instructions

##### Note: This guide is assuming you are running OSX Lion

### postgres
  1. Install homebrew: https://github.com/mxcl/homebrew/wiki/installation
  1. `brew install postgresql` (optional, you may already have these)
  1. Initialize Postgres db: `initdb /usr/local/var/postgres`
  1. Set ownership of pgsql socket: `sudo chown $USER /var/pgsql_socket/`
  1. Run script to correct Lion's Postgres path: `curl http://nextmarvel.net/blog/downloads/fixBrewLionPostgres.sh | sh`
  1. Create an auto-start launchctl script per `brew info postgres`'s instructions
  1. Create _postgres db user: `createuser -a -d postgres`
  1. Verify postgres is working: `psql template1 -U _postgres`

### git
  1. `brew install git`

### ruby
  1. Install rvm or rbenv: https://rvm.io/rvm/install/ or https://github.com/sstephenson/rbenv#section_2
  1. rvm install 1.9.3 or rbenv install 1.9.3-p194
  1. rvm use 1.9.3-p125 or rbenv global 1.9.3-p194
    
### app
  1. Clone the repo from github, `git clone git@github.com:rescuedcode/StaffPlan.git`
  1. cd to the app and `bundle`
  1. `rake db:create`
  1. `git remote add heroku git@heroku.com:staffplan.git` (to enable deploying to heroku)
  1. bootstrap local database using prod data: `heroku db:pull` (You may heroku credentials for this. You'll also need to be given permission explicitly.)
  1. run the app!: `bundle exec rails s`