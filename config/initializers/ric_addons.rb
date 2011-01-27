# Be sure to restart your server when you modify this file.

#Septober::Application.config.session_store :cookie_store, :key => '_septober_session'

RicAddons.yellow('Adding to this app (probly septober) the Searchable as for AdvancedRailsRecipes.24')
ActiveRecord::Base.extend Searchable

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Septober::Application.config.session_store :active_record_store
