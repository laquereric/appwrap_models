# frozen_string_literal: true

require_relative "appwrap_models/version"
require_relative "appwrap_models/model_extractor"
require_relative "appwrap_models/railtie" if defined?(Rails::Railtie)

module AppwrapModels
  class Error < StandardError; end
end

