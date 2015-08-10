# dot env sometimes doesn't get loaded properly with the rails console
Dotenv::Railtie.load unless ENV['BRAINTREE_ENVIRONMENT']
if ENV['BRAINTREE_ENVIRONMENT']
  Braintree::Configuration.environment = ENV['BRAINTREE_ENVIRONMENT'].to_sym
  Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  Braintree::Configuration.public_key  = ENV['BRAINTREE_PUBLIC_KEY']
  Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
end
