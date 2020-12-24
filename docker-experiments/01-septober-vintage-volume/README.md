
Idea here is to launch septober as in / in a new /var/www/app-volume so wehn you call docker tun bash 
you can easily troubleshoot the differences from "OLD working copy" and "NEW not working copy".
Basically the genius idea i had below the shower is to treat existing /var/www as gospel, and
try everything on a NEW dir where maybe Gemfile does NOT work with old libs.. and we need to learn to install them.

## Plan

1. Copy original dockerfile: where codebase is in /var/www-public/septober/
2. Compile everything as we dont want to touch existing workflow (we fail if and only if original fails.)
3. Then we build original and we create a SECOND directory, like:  /var/www-public/septober-vintage-volume/
4. We run with bash and then try to run entrypoint on both sides and see if they both works.
5. When they do, we run in SECOND directory and make changes to env and commit on our nice volume the changes :) 
    
    VELOCITY INCREASED!

## implementation 

1. Done
2. Done
3. Done
4. works on first, the second doesnt. Complains Gemfile has mysql stuff. Of course, I need to REDO what original Dockerfile 
   does.

   Two things th dockerfile does:

RUN mv ./config/initializers/abstract_mysql2_adapter.rb ./config/initializers/abstract_mysql2_adapter.rb.inutile
RUN bundle install

The second I do, the first I'd rather not and fix it FOREVER (remove the file)

Added a TODO to the SQLITE DB. It works!

Check the local file system if it changed: 

$ git status

Changes not staged for commit:
	modified:   db/development.sqlite3

and it did! Experiment succesful!