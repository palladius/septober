module ApplicationHelper
  # moved to ric_addons.rb
  
  #$APP2 = {
  #    # TODO put me in YML..
  #  :name        => 'Septober',
  #  :headline    => 'Yet another ToDo Application, with simplicity kept in mind. 
  #    Procrastinators unite.. tomorrow! (op. cit.)',
  #  :version     => File.open("#{Rails.root}/VERSION" ).read ,  # RAILS_ROOT
  #  :license     => File.open("#{Rails.root}/MIT-LICENSE" ).read ,
  #  :copyright   => 'Copyright 2011-11 Some rights reserved',
  #  :email       => 'riccardo.carlesso@gmail.com',
  #}
  $APP[:base_models] = %w{todos projects ric_addons#index mah } 
  #$APP[:foo] = :bar
  
  $APP_NAME = $APP[:name] + " (obsolete: user $APP instead)"
  $APP_HEADLINE = $APP[:headline]
  #$APP_VERSION = File.read
  #File.open(RAILS_ROOT + '/VERSION' ).read
  $debug_info ||= {}
  @base_models = %w{todos projects ric_addons#index mah }
end
