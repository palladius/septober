# Septober

[![Build Status](https://secure.travis-ci.org/palladius/septober.png)](http://travis-ci.org/palladius/septober)
 
 A screenshot:
 <img src='http://www.palladius.it/palladius.jpg' height='100' />
 <img src='https://github.com/palladius/septober/raw/master/doc/Screenshot.png' height='100' />

 Author: Riccardo Carlesso <rusko@palladius.it>

* [Demo Site](http://septober.heroku.com/)
* [Screenshot](https://github.com/palladius/septober/raw/master/doc/Screenshot.png)

<img src="https://github.com/palladius/septober/raw/master/doc/Screenshot.png" width="300" alt="Screenshot for Septober" align='right' />


## Synopsis 

  Welcome to my first vanilla RubyOnRails Application generated with my generator.
  
## INSTALL 

  You have to install `sqlite3` gem dependencies. Thy this out:

	`make install`
	`bundle install`

  * Rails: `3.X`
  * Ruby: `1.9.3p484 ` # or at least so says the docker container
  
# Features 
  
  - Language: RoR 3 !!! Today its a bug I know :)
  
  - Multi-Project. Each project can be home visible or not
   .Projects can be hidden in home page if you want 
  
   
  - A working CLI thru simple API (messy code but simple use) and a simple script: `bin/septober`:
    - supports colors from project color thanks to 'ric' gem :)
		- supports adding, listing and marking as done
    - Cli is ready to go in development AND in production on my heroku small server..

  - Todos have the property of:
    - bookmark, dependencies, procrastinate, hide_until date, where they are, done/undeone/toggle...
    - Quick create supports some regex ("buy milks by tomorrow!!" automatically sets the due date AND raises priority by 2)

  - Trying to adhere to [Semantic Versioning](http://semver.org/)

## CLI

<img src="https://github.com/palladius/septober/raw/master/doc/CliScreenshot.png" width="300" alt="Screenshot for Septober CLI" align='right' />

Usage (for use of bin/septober guides you thru the creation of `~/.septober.yml` config file):

	bin/septober list
	bin/septober add 'Buy the milk by tomorrow!!'
	bin/septober show 45
	bin/septober done 45

### Cloud Shell Walkthrough

Use this Cloud Shell walkthrough for a hands-on example.

[![Open this project in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/palladius/septober&page=editor&tutorial=walkthrough.md)

## Dockerization

This is complex topic so it deserves a paragraph here :)
Until 2020-12-24 I had two branches of Dockerization:
* in this `Dockerfile` with the sqlite containerization. Due to bugs and pains in Mysql I jus t overwrote the Gemfile making the system forget that mysql is even a thing. Note: This has been recently changed, read on.
* a private `Dockerfile` which inherits from this, adds a private user/password/hostname to my prod DB and loads it, creating `septober-mysql` which only works in prod.

This was painful as I had two things to maintain, dockerwise. So I finally merged the two creating a third docker in `docker-experiments/01-...`. This allows me to build
a local docker image mounting the code as a volume, which allows me to fix bugs on th fly and not have to commit, push and hope (AKA "plug and pray").
Now I'm there and the Dockerfile suppoerts both sqlite and mysql, and sqlite is set up for dev, and mysql for prod. Prod has also a dumb DB in case you want to set it up
(I just need to add a routine to the ./entrypoint-8080.sh which accepts a db_setup_and_run for an empty DB on docker-compose). Yet to come!

There's now a third docker that makes sense only for local dev (not to be pushed or user as it needs a liquid FS to dev locally):

* `cd docker-experiments/02-septober-vintage-volume-singlerepo/ `
* `make docker-run-volume-prod `
* Note: once in the container the LOCAL dir is the untouched one - I left it for additional troubleshooting power.
* `cd /var/www-public/02-septober-vintage-volume-singlerepo/`
* RAILS_ENV=development ./entrypoint-8080.sh 
* And you're in! Do all changes you want and they'll reflect on the docker being run - only 9 times in the past since ruby1.8 and rails2 is impossible to run on my personal computer today (God knows I've tried).
* Login as guest/guest in dev.

### Docker Compose

To get a gist of sqlite3, just run rails s and you're game.

To get a gist of MySQL, I set up a working docker compose. Therefore you can just do this:

* `docker-compose up`
* Open `http://localhost:8080/login`  (*)
* Log in as `guest` // `seed-guest`. And you're in! 

(*) Note sometime I saw a bug in the / endpoint, so you might have to go to login directly since home failed. Hope it doesnt reoccur.

To troubleshoot users, you can do this (love `docker-compose`!):

    echo User.all | docker-compose exec septober rails c

### BUGS

- Search engine is still broken (see search addon!)
- Add DONE Ajax button... (add 3 routes to todos: toggle, resolve, unr-esolve )
    
### TODO 

	- Add Google/Facebook login!
  
  - fix bugs (eg you cant DELETE a TODO as of now just arechive them!)

  -  Things to add to this mirabolant script:
    - remove todos (They're app specific, consider them a proof of concept)
    - ask for root password on create (in rake db:seed more security) 
    - Add tags to models.. and appropriate `acts_as_taggable` gem
    
