source 'https://rubygems.org'

gem 'rails', '4.1.5'
gem 'rails-api', '0.2.1'

gem 'pg', '0.17.1'
gem 'bunny', '~> 1.5'

gem 'logstasher', '0.5.0'
gem 'airbrake', '4.0.0'
gem 'plek', '~> 1.9'

gem 'unicorn', '4.8.2'

group :development do
  gem 'spring'
end

group :development, :test do
  gem 'pact'
  gem 'rspec-rails', '~> 3.0.2'
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'shoulda-matchers', require: false
  gem 'childprocess', '~> 0.5.5'

  gem 'simplecov', '0.8.2', :require => false
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter_rspec', '~> 1.0.0'
end
