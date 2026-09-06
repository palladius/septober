#!/bin/bash
PORT=3001
REPO_DIR="/Users/riccardo/git/septober"

if ! lsof -i :$PORT >/dev/null 2>&1; then
  export PATH="/Users/riccardo/.rbenv/shims:$PATH"
  cd "$REPO_DIR" && RBENV_VERSION=3.4.5 bin/rails s -p $PORT -e development -d
  for i in {1..30}; do
    if curl -s "http://localhost:$PORT/healthz" >/dev/null 2>&1; then
      break
    fi
    sleep 0.2
  done
fi

if [ -d "/Applications/Google Chrome.app" ]; then
  exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="http://localhost:$PORT/"
else
  exec open "http://localhost:$PORT/"
fi
