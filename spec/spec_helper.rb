# frozen_string_literal: true

require "appwrap_models"
require "active_record"
require "rails"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Setup test database
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:"
    )
  end

  # Clean up after each test
  config.after(:each) do
    FileUtils.rm_rf("spec/tmp") if File.exist?("spec/tmp")
  end
end

