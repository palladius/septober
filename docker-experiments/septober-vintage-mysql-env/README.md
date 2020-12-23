
The idea here is to just change the code for mysql to remove my private mysql file
and instead change ALL production to use something like:

   <%= ENV["MYSQL_USER"] >
   
This way it will be able to BOTH workj with a very simple `docker-compose` and with my prod situation,
just passing ENV. This is a long due work Ricc.