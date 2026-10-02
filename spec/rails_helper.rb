require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"
require "n_plus_one_control/rspec"

Rails.root.glob("spec/support/**/*.rb").sort.each { |file| require file }

ActiveRecord::Migration.maintain_test_schema!
allowed_endpoints = []
selenium_host = ENV["SELENIUM_HOST"].to_s.strip
app_host = ENV["CAPYBARA_SERVER_HOST"].to_s.strip
app_port = ENV["CAPYBARA_SERVER_PORT"].to_s.strip
allowed_endpoints << "http://#{selenium_host}:4444" unless selenium_host.empty?
allowed_endpoints << "http://#{app_host}:#{Integer(app_port, 10)}" unless app_host.empty? || app_port.empty?
WebMock.disable_net_connect!(allow_localhost: true, allow: allowed_endpoints)

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.file_fixture_path = Rails.root.join("spec/fixtures/files")
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  config.around do |example|
    Bullet.profile { example.run }
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
