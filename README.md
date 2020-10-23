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
  
# Features 
  
  - Language: RoR 3 !!!
  
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

### BUGS

- Search engine is still broken (see search addon!)
- Add DONE Ajax button... (add 3 routes to todos: toggle, resolve, unr-esolve )
    
### TODO 

	- Add Facebook login!
  
    Things to add to this mirabolant script:
    - remove todos (They're app specific, consider them a proof of concept)
    - ask for root password on create (in rake db:seed more security) 
    - Add tags to models.. and appropriate `acts_as_taggable` gem
    
