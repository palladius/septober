class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include Searchable
  protect_from_forgery
end
