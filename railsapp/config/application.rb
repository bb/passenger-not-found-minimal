require_relative "boot"

require "rails"

%w(
  action_controller/railtie
  action_view/railtie
  action_text/engine
  rails/test_unit/railtie
).each do |railtie|
  begin # rubocop:disable Style/RedundantBegin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = "Berlin"
    config.i18n.default_locale = :de

    # config.eager_load_paths << Rails.root.join("extras")

  end
end
