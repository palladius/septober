require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Septober
  class Application < Rails::Application
    
    config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.i18n.default_locale = :it

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.to_prepare do
      RicAddons.yellow('Adding to this app (probly septober) the Searchable as for AdvancedRailsRecipes.24')
      #ActiveRecord::Base.extend Searchable
      ActiveRecord::Base.extend SearchableCopy

      $APP = {
        :name        => 'Septober is my Super-Duper App, since 2011!', # (config/initializers/ric_addons.rb)',
        :headline    => 'Procrastinators unite.. tomorrow!', # (config/initializers/ric_addons.rb)',
        :version     => File.open("#{Rails.root}/VERSION" ).read.chomp ,  # RAILS_ROOT
        :copyright   => 'Copyright 2011-20 A few rights reserved (see LICENSE)',
        :email       => 'riccardo.carlesso+septober@gmail.com',
        :author_name => 'Riccardo Carlesso',
      #  :author      => 'Riccardo Carlesso <riccardo.carlesso@gmail.com>',
      }

      $APP[:license] = File.open("#{Rails.root}/LICENSE" ).read rescue "No /LICENSE file found. Please add it to the root directory and Ill load it automatically for you ;)"
      $APP[:author] = "#{$APP[:author_name]} <#{$APP[:email]}>"
      $APP[:docker] = "See pages/about.html"
      $APP[:messaggio_occasionale] = ENV['MESSAGGIO_OCCASIONALE']
    end
  end
end