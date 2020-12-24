module ApplicationHelper
  # moved to ric_addons.rb
  
  #TODO pull from conf/application.yml
  
  $APP[:name]     = 'Septober'
  $APP[:headline] = 'Yet another ToDo Application, with simplicity kept in mind. 
  #    Procrastinators unite.. tomorrow! (op. cit.)'
  
  $APP[:base_models] = %w{todos projects tags pages#index pages#license pages#healthz } #  ric_addons#index 
  $APP_NAME = $APP[:name] #+ " (obsolete: user $APP[:name] instead)"
  $APP_HEADLINE = $APP[:headline] #+ " (obsolete: use $APP[:headline] instead)"
  $debug_info ||= {}
end
