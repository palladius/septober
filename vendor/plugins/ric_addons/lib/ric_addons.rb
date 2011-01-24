# RicPlugin

# Copied from book RailsRecipes#1 pag 238.
module RicAddons
  
  def search(query, fields, options = {})
    find :all, options.merge(:conditions => [[fields].flatten.map { |f| "#{f} LIKE :query"}.join(' OR '), {:query => "%#{query}%" } ] )  
  end
  
  def self.yellow(str)
    "[RicAddons] \033[1;33m#{str}\033[0m"
  end
  
  def self.pyellow(str)
    puts yellow(str)
  end
  
  def self.ric_websites_ring
    {
      'RAB'   => 'http://ric_addressbook.heroku.com' ,
      'Pasta' => 'http://pasta.heroku.com' ,
      
    }
  end
  
  def self.ric_addons_set_routes(map_object)
    # Routes version 1.0.2
    puts(yellow("Adding routes to a #{map_object.class}.."))
    map_object.get "ric_addons"        => "ric_addons#index"
    map_object.get "ric_addons/about"
    map_object.get "ric_addons/index"
    map_object.get "ric_addons/search"
    map_object.get "ric_addons/test"
  end
end