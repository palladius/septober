source 'http://rubygems.org'

ruby "1.9.3" # septober image used this: 1.9.3-p484

gem 'rails',            '3.0.3'
#gem "activerecord", ">= 3.2.19" # vulnerability CRITICAL: https://github.com/palladius/septober/network/alert/Gemfile.lock/activerecord/open
#gem 'rails',            '>= 3.0.3'
gem "ric",              '>= 0.11.3'
gem 'sqlite3-ruby',     :require => 'sqlite3'
gem "nifty-generators"  #, :group => :development
#gem "bcrypt-ruby",      :require => "bcrypt"
#gem 'bcrypt-ruby',      '3.1.5' ,  :require => "bcrypt"
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'acts-as-taggable-on'                         # For tags

gem "jquery-rails",     '>= 0.2.6'   # For InPlaceEditing
gem "on_the_spot"                    # .. https://github.com/nathanvda/on_the_spot 

gem "mocha",            :group => :test
gem 'wirble', :groups => [:development,:test]
#gem 'autotest', :groups => [:development,:test]
#gem 'ZenTest', :groups => [:development,:test]
# If you are developing actively, try this:
#gem "ric", :path => "~/git/ric"

# trovata in: https://stackoverflow.com/questions/9609985/please-install-mysql-adapter-gem-install-activerecord-mysql-adapter
#gem 'mysql2', "~>0.3.11"
# even better: https://stackoverflow.com/questions/51228905/rails-error-installing-mysql2-mysql2-0-3-20
gem 'mysql2', '0.3.20'
gem 'activerecord-mysql2-adapter'
