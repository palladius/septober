module ApplicationHelper
  # moved to ric_addons.rb
  
  #$APP2 = {
  #    # TODO put me in YML..
  #  :name        => 'Septober',
  #  :version     => File.open("#{Rails.root}/VERSION" ).read ,  # RAILS_ROOT
  #  :license     => File.open("#{Rails.root}/MIT-LICENSE" ).read ,
  #  :copyright   => 'Copyright 2011-11 Some rights reserved',
  #  :email       => 'riccardo.carlesso@gmail.com',
  #}
  $APP[:name]     = 'Septober'
  $APP[:headline] = 'Yet another ToDo Application, with simplicity kept in mind. 
  #    Procrastinators unite.. tomorrow! (op. cit.)'
  $APP[:base_models] = %w{todos projects ric_addons#index mah  pages/index } 
  $APP_NAME = $APP[:name] + " (obsolete: user $APP[:name] instead)"
  $APP_HEADLINE = $APP[:headline] + " (obsolete: use $APP[:headline] instead)"
  $debug_info ||= {}
  @base_models = %w{todos projects ric_addons#index mah }
end
