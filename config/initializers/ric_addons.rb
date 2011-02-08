# Be sure to restart your server when you modify this file.

#Septober::Application.config.session_store :cookie_store, :key => '_septober_session'

RicAddons.yellow('Adding to this app (probly septober) the Searchable as for AdvancedRailsRecipes.24')
#ActiveRecord::Base.extend Searchable
ActiveRecord::Base.extend SearchableCopy

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Septober::Application.config.session_store :active_record_store

$APP = {
  :name        => 'Put your App name here (config/initializers/ric_addons.rb)',
  :headline    => 'Put your App Headline here (config/initializers/ric_addons.rb)',
  :version     => File.open("#{Rails.root}/VERSION" ).read ,  # RAILS_ROOT
  :copyright   => 'Copyright 2011-11 A few rights reserved (see LICENSE)',
  :email       => 'riccardo.carlesso@gmail.com',
  :author_name => 'Riccardo Carlesso'
#  :author      => 'Riccardo Carlesso <riccardo.carlesso@gmail.com>',
}

$APP[:license] = File.open("#{Rails.root}/LICENSE" ).read rescue "No /LICENSE file found. Please add it to the root directory and Ill load it automatically for you ;)"
$APP[:author] = "#{$APP[:author_name]} <#{$APP[:email]}>"