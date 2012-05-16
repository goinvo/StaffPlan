## StaffPlan



##############################
Setup Instructions

By: Christian Hogan

Last edit: 4/1/2012
##############################

Notes:

This guide is assuming you are running OSX Lion. Some commands may vary, but most should be consistent across OSX and linux platforms.

--------------

1) Clone the repository from github
	(If you're reading this, you've probably already done that.)
	
	git clone git@github.com:rescuedcode/StaffPlan.git

#

2) Install rvm
	
	bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

#

3) Install ruby 1.9.3-p125

	rvm install 1.9.3-p125

#
	
4) Set 1.9.3-p125 to your current version

	rvm use 1.9.3-p125

#
	
5) Get some gems

	gem install rails bundler taps

#

6) Install Homebrew

	/usr/bin/ruby -e "$(/usr/bin/curl -fksSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"

#

7) Install / configure postgres
	
	Install:

	brew install postgresql


	Initialize Postgres db:

	initdb /usr/local/var/postgres
	
	
	Set ownership of pgsql socket:
	
	sudo chown $USER /var/pgsql_socket/
	
	
	Run script to correct Lion's Postgres path:
	
	curl http://nextmarvel.net/blog/downloads/fixBrewLionPostgres.sh | sh
	
	
	Create an auto-start launchctl script:
	
	cp /usr/local/Cellar/postgresql/9.1.3/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
	launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist

	
	Create _postgres db user:
	
	createuser -a -d postgres
	
	
	Verify postgres is working:
	
	psql template1 -U _postgres
	
	
	Create staffplan development database:
	
	createdb staff_plan_development

#

8) Change to app directory

	cd /workspace/StaffPlan

#

9) Trigger the bundle install

	bundle install
	
#

10) Add heroku config

	git remote add heroku git@heroku.com:staffplan.git

#

11) Setup the database

	heroku db:pull
	
	** You need heroku credentials for this. Enter them when prompted **

#

12)	make sure development.log is writable

	chmod 666 logs/development.log
	
#
	
13) Run the app

	bundle exec rails s
	
	
	
	
