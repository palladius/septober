# From: http://izumi.plan99.net/manuals/creating_plugins-8f53e4d6.html

module RicAddons #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions
      def ric_addons
        @set.add_route("/ric_addons", {:controller => "ric_addons_controller", :action => "index"})
      end
    end
  end
end

# Copied from: http://snipt.net/oskarnrk/add-routes-with-a-rails-plugin-or-gem/
# Redefine clear! method to do nothing (usually it erases the routes)
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end
# Let the gem/plugin add the routes
ActionController::Routing::Routes.draw do |map|
  # some routes...
  #get 'ric_addonzzz'
  get "ric_addons"        => "ric_addons#index"
  get "ric_addons/about"
  get "ric_addons/index"
  get "ric_addons/search"
  get "ric_addons/test"
end

=begin
  What it should be:
  
  # RicAddons::ric_addons_set_routes(self)
  # # Routes version 1.0.2
  # get "ric_addons"        => "ric_addons#index"
  # get "ric_addons/about"
  # get "ric_addons/index"
  # get "ric_addons/search"
  # get "ric_addons/test"
  ### /RicAddons::Routes
  ####################################

=end
