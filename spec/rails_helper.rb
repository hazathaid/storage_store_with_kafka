require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# Pastikan migration selalu up-to-date
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Gunakan fixture_path kalau pakai fixtures
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  # Gunakan transactional fixtures
  config.use_transactional_fixtures = true

  # Auto infer type berdasarkan lokasi file (misal: spec/controllers => type: :controller)
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
