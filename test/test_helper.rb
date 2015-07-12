ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'hashie'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  def create_signup(attrs = {})
    Signup.create!(attrs.merge({
        access_token: 'access-token',
        instagram_username: 'jillsmith',
        instagram_id: '123456'
      }))
  end  
end
