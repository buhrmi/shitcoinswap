require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shitcoins
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    
    config.eager_load_paths += %W(#{config.root}/lib)
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.assets.prefix = '/build'
    config.i18n.fallbacks = [:en]

    ActionMailer::Base.smtp_settings = {
      :address        => ENV['SMTP_SERVER'],
      :user_name      => ENV['SMTP_USER'],
      :password       => ENV['SMTP_PASSWORD'],
      :port           => ENV['SMTP_PORT']
    }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
