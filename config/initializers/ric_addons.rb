# Be sure to restart your server when you modify this file.

#Septober::Application.config.session_store :cookie_store, :key => '_septober_session'

RicAddons.yellow('Adding to this app (probly septober) the Searchable as for AdvancedRailsRecipes.24')
ActiveRecord::Base.extend Searchable

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Septober::Application.config.session_store :active_record_store

$APP = {
  :name        => 'Put your App name here (config/initializers/ric_addons.rb)'
  #:name        => 'Septober',
  :headline    => 'Put your App Headline here (config/initializers/ric_addons.rb)',
  #:headline    => 'Yet another ToDo Application, with simplicity kept in mind.   Procrastinators unite.. tomorrow! (op. cit.)',
  :version     => File.open("#{Rails.root}/VERSION" ).read ,  # RAILS_ROOT
  :license     => File.open("#{Rails.root}/LICENSE" ).read ,
  :copyright   => 'Copyright 2011-11 A few rights reserved (see LICENSE)',
  # :email       => '',
  :author      => 'Riccardo Carlesso <riccardo.carlesso@gmail.com>'
}