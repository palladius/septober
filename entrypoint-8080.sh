#!/bin/bash

# This is a best pracice entrypoint which does two things:
# 1. Preps this shitty ruby1.9 environment.
# 2. Is ready to execute other commands, (say rake db:migrate or something)

# First of all we source .env as we might need to override something.
source .env

VER="$(cat VERSION)"
MYPORT="${PORT:-8080}"
APP_NAME="${APPNAME:-entrypoint-sobenme}"
ENTRYPOINT_VERSION="0.3"

function verbose_echo() {
    echo "[ep8080][$APP_NAME-v$VER] $(echo "$*" | lolcat)" | lolcat

}

#export MESSAGGIO_OCCASIONALE="Test Entrypoint8080 which is NOW the default entrypoint in docker, woohoo! TBD removeme once it's proven to work so we can use the ones from docker apps."

verbose_echo "BEGIN. $0 called with args: '$*'" # | lolcat

# if DEV or PROD we further source appropriate .env.$ENV if it exists.
if [ -f ".env.$RAILS_ENV" ]; then
    verbose_echo "EnvFile .env.$RAILS_ENV found! Sourcing it! Sluuuuurp!"
    source .env.$RAILS_ENV
else
    verbose_echo "EnvFile .env.$RAILS_ENV not found: no biggie. Skipping"
fi 
    
if printenv RAILS_ENV | grep -q production ; then
    verbose_echo "Riccardo I believe this is PROD Lets scagnozz the dogs on port $MYPORT"
    export RAILS_LOG_TO_STDOUT=yesplease 
    export RAILS_ENV=production
    export RACK_ENV production

    #source .env # Nope, already done my friend.
    #source .env
    if [ -f .env.production ]; then
        source .env.production
    fi 

   # useless for septober too old!
    bundle install

    bundle exec rake db:migrate

    bundle exec rails s -b 0.0.0.0 -p $MYPORT
else
    verbose_echo "Riccardo I believe this is DEV Lets keep it easy peasy on port $MYPORT"
    #source .env # Nope, already done my friend.
    # TODO create and source .env.development
    bundle exec rails s -b 0.0.0.0 -p $MYPORT
fi

echo "[$APP_NAME-v$VER-entrypoint] END. Calling now Args in case you gave me: $*"
"$@"
