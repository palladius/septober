#!/bin/bash

# questo supera ed estende il RUN IN PROD basandosi sulla sola regola di RAILS_ENV :) 
# prepare
# ActionView::Template::Error (The asset "home.png" is not present in the asset pipeline.
. .env

VER="$(cat VERSION)"
MYPORT="${PORT:-8080}"
APP_NAME="${APPNAME:-entrypoint-sobenme}"

function verbose_echo() {
    echo "[ep8080][$APP_NAME-v$VER] $(echo "$*" | lolcat)" | lolcat

}

#export MESSAGGIO_OCCASIONALE="Test Entrypoint8080 which is NOW the default entrypoint in docker, woohoo! TBD removeme once it's proven to work so we can use the ones from docker apps."

verbose_echo "BEGIN. $0 called with args: '$*'" # | lolcat
    
if printenv RAILS_ENV | grep -q production ; then
    verbose_echo "Riccardo I believe this is PROD Lets scagnozz the dogs on port $MYPORT"
    export RAILS_LOG_TO_STDOUT=yesplease 
    export RAILS_ENV=production
    export RACK_ENV production

    source .env
    source .env.production

   # useless for septober too old!
    bundle install

    bundle exec rake db:migrate

    bundle exec rails s -b 0.0.0.0 -p $MYPORT
else
    verbose_echo "Riccardo I believe this is DEV Lets keep it easy peasy on port $MYPORT"
    source .env
    # TODO create and source .env.development
    bundle exec rails s -b 0.0.0.0 -p $MYPORT
fi

echo "[$APP_NAME-v$VER-entrypoint] END. Calling now Args in case you gave me: $*"
"$@"
