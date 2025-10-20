# frozen_string_literal: true

require_relative "lib/appwrap_models/version"

Gem::Specification.new do |spec|
  spec.name = "appwrap_models"
  spec.version = AppwrapModels::VERSION
  spec.authors = ["Appwrap Team"]
  spec.email = ["info@appwrap.io"]

  spec.summary = "Extract Rails models to JSONL format with UUIDs"
  spec.description = "A Ruby gem that extracts model information from Rails applications and writes them to appwrap/routes.jsonl with assigned UUIDs"
  spec.homepage = "https://github.com/appwrap/appwrap_models"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/appwrap/appwrap_models"
  spec.metadata["changelog_uri"] = "https://github.com/appwrap/appwrap_models/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    Dir["{lib}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"
end

