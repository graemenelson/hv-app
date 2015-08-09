Shoryuken::EnvironmentLoader.load( config_file: (Rails.root + 'config' + 'shoryuken.yml'), rails: true ) unless Rails.env.test?
Shoryuken.active_job_queue_name_prefixing = true
Shoryuken.configure_server do |config|
  Rails.logger = Shoryuken::Logging.logger
end
