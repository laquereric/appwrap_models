# frozen_string_literal: true

namespace :appwrap do
  namespace :models do
    desc "Extract Rails models to appwrap/routes.jsonl with UUIDs"
    task extract: :environment do
      require "appwrap_models"
      
      puts "Starting model extraction..."
      puts "Rails root: #{Rails.root}"
      
      extractor = AppwrapModels::ModelExtractor.new
      count = extractor.extract
      
      puts "Extraction complete! #{count} models extracted."
    rescue StandardError => e
      puts "Error during extraction: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
end

