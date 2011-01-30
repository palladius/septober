module ApplicationHelper
  $APP = {
      # TODO put me in YML..
    :name => 'Septober',
    :headline => 'Yet another ToDo Application, with simplicity kept in mind. 
      Procrastinators unite.. tomorrow! (op. cit.)',
    :version =>  File.open(RAILS_ROOT + '/VERSION' ).read ,
    :copyright => 'Copyright 2011-11 Some rights reserved',
    :email => 'riccardo.carlesso@gmail.com',
  }
  $APP_NAME = $APP[:name]
  $APP_HEADLINE = $APP[:headline]
  #$APP_VERSION = File.read
  #File.open(RAILS_ROOT + '/VERSION' ).read
end
