# encoding: utf-8
class ApplicationController < ActionController::Base
  include ControllerAuthentication
  include SearchableCopy
  #include FakeStuff
  protect_from_forgery

  rescue_from ActiveRecord::ConnectionNotEstablished, Mysql2::Error do |exception|
    logger.error "[Septober][DB_TIMEOUT] Database connection error: #{exception.class} - #{exception.message}"
    respond_to do |format|
      format.html { render :text => "<h1>[Septober is Alive]</h1><p>Problemi di connessione al DB (timeout 5-10s). L'applicazione e in esecuzione, riprova a breve.</p>", :status => :service_unavailable }
      format.json { render :json => { :status => "degraded", :error => "Database connection timeout. Application is alive, please retry shortly." }, :status => :service_unavailable }
      format.xml  { render :xml  => "<error><status>degraded</status><message>Database connection timeout. Application is alive.</message></error>", :status => :service_unavailable }
    end
  end
end
