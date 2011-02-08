class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include SearchableCopy
  protect_from_forgery
end
