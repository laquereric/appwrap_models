# frozen_string_literal: true

require "appwrap_models"
require "active_record"
require "fileutils"
require "tmpdir"
require "json"

# Setup test environment
Before do
  @test_dir = Dir.mktmpdir
  @output_dir = File.join(@test_dir, "appwrap")
  @output_file = File.join(@output_dir, "routes.jsonl")

  # Mock Rails
  stub_const("Rails", Class.new do
    class << self
      attr_accessor :test_dir

      def root
        Pathname.new(test_dir)
      end

      def application
        @application ||= Class.new do
          def self.eager_load!
            # No-op for testing
          end
        end.new
      end
    end
  end)

  Rails.test_dir = @test_dir

  # Setup database
  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: ":memory:"
  )
end

After do
  FileUtils.rm_rf(@test_dir) if @test_dir && File.exist?(@test_dir)
end

def stub_const(name, value)
  Object.const_set(name, value) unless Object.const_defined?(name)
end

