
# dove l'ho trovato?!?
# https://stackoverflow.com/questions/33742967/primary-key-issue-with-creating-tables-in-rails-using-rake-dbmigrate-command-wi
require 'active_record/connection_adapters/mysql2_adapter'

class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"e
nd

