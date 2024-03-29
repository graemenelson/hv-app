source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# make sure dotenv gets loaded before all the other gems
# so we can use the .dotfile
gem 'dotenv-rails', :require => 'dotenv/rails-now'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

##################
# Haaave additions

# Server
gem 'puma'

# Services
gem 'instagram'
gem 'braintree'
gem 'aws-sdk-core'

# Bootstrap
gem 'bootstrap-sass', '~> 3.3.5.1'

# Persistence
gem 'pg'

# Jobs
gem 'shoryuken'

# Views
gem 'simple_form'
gem 'gon'

# Utilities
gem 'hashie', '~> 3.4.2'
gem 'foreman'

# Security
gem 'bcrypt', '~> 3.1.7'
gem 'strongbox'

group :development do
  gem 'bullet'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

end

group :test do
  gem 'webmock'
  gem 'mocha'
end
