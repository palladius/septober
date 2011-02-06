module ApplicationHelper
  # moved to ric_addons.rb
  
  $APP[:name]     = 'Septober'
  $APP[:headline] = 'Yet another ToDo Application, with simplicity kept in mind. 
  #    Procrastinators unite.. tomorrow! (op. cit.)'
  
  $APP[:base_models] = %w{todos projects ric_addons#index mah  pages/index } 
  $APP_NAME = $APP[:name] #+ " (obsolete: user $APP[:name] instead)"
  $APP_HEADLINE = $APP[:headline] #+ " (obsolete: use $APP[:headline] instead)"
  $debug_info ||= {}
  @base_models = %w{todos projectstags pages#index } #  ric_addons#index 
end
