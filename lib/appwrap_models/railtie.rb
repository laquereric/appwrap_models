# frozen_string_literal: true

module AppwrapModels
  class Railtie < Rails::Railtie
    railtie_name :appwrap_models

    rake_tasks do
      load "appwrap_models/tasks/appwrap_models.rake"
    end
  end
end

