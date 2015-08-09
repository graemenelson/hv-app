require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HaaaveApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.filter_parameters += [:password,
                                 :email,
                                 :access_token,
                                 :payment_method_nonce]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.eager_load_paths += %W(
      #{config.root}/app/mixins
      #{config.root}/app/services
      #{config.root}/app/validators
      #{config.root}/app/jobs
      #{config.root}/app/presenters
       )

    # prefix ActiveJob queue name with rails environment
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_adapter = :shoryuken

    config.generators do |g|
      g.test_framework  :test_unit, fixture: false
      g.stylesheets     false
      g.javascripts     false
    end
  end
end
