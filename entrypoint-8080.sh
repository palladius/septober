#!/bin/bash

# questo supera ed estende il RUN IN PROD basandosi sulla sola regola di RAILS_ENV :) 
# prepare
# ActionView::Template::Error (The asset "home.png" is not present in the asset pipeline.
. .env

VER="$(cat VERSION)"
MYPORT="${PORT:-8080}"
APP_NAME="${APPNAME:-entrypoint-sobenme}"

export MESSAGGIO_OCCASIONALE="Test MsgOccas in Entrypoint8080... TBD removeme once it's proven to work."

echo "[$APP_NAME-v$VER-entrypoint] BEGIN. Args: $*"
    
if printenv RAILS_ENV | grep -q production ; then
    echo "[$APP_NAME-v$VER-entrypoint] Riccardo I believe this is PROD Lets scagnozz the dogs on port $MYPORT"
    export RAILS_LOG_TO_STDOUT=yesplease 
    export RAILS_ENV=production
    export RACK_ENV production

    source .env
    source .env.production

   # useless for septober too old!
    #bundle exec rake assets:precompile
    bundle install

    bundle exec rake db:migrate

    bundle exec rails s -b 0.0.0.0 -p $MYPORT
else
    echo "[$APP_NAME-v$VER-entrypoint] Riccardo I believe this is DEV Lets keep it easy peasy on port $MYPORT"
    source .env
    bundle exec rake assets:precompile
    bundle exec rails s -b 0.0.0.0 -p $MYPORT
fi

echo "[$APP_NAME-v$VER-entrypoint] END. Calling now Args in case you gave me: $*"
"$@"
