class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include SearchableCopy
  include FakeStuff
  protect_from_forgery
end
