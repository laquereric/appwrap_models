# frozen_string_literal: true

require "json"
require "securerandom"
require "fileutils"

module AppwrapModels
  class ModelExtractor
    attr_reader :rails_root, :output_dir

    def initialize(rails_root: Rails.root, output_dir: "appwrap")
      @rails_root = rails_root
      @output_dir = File.join(rails_root, output_dir)
    end

    def extract
      ensure_output_directory
      models = find_models
      models_data = models.map { |model| extract_model_info(model) }
      write_to_jsonl(models_data)
      
      puts "✓ Extracted #{models_data.size} models to #{output_file}"
      models_data.size
    end

    private

    def ensure_output_directory
      FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
    end

    def output_file
      File.join(output_dir, "routes.jsonl")
    end

    def find_models
      # Eager load all models
      Rails.application.eager_load! if defined?(Rails)
      
      # Find all classes that inherit from ActiveRecord::Base
      models = ActiveRecord::Base.descendants.select do |model|
        # Exclude abstract classes and models without table names
        !model.abstract_class? && model.table_exists?
      end
      
      models.sort_by(&:name)
    end

    def extract_model_info(model)
      {
        uuid: generate_uuid,
        name: model.name,
        table_name: model.table_name,
        columns: extract_columns(model),
        associations: extract_associations(model),
        validations: extract_validations(model)
      }
    end

    def extract_columns(model)
      model.columns.map do |column|
        {
          name: column.name,
          type: column.type.to_s,
          sql_type: column.sql_type,
          null: column.null,
          default: column.default,
          primary: column.name == model.primary_key
        }
      end
    end

    def extract_associations(model)
      associations = {
        belongs_to: [],
        has_many: [],
        has_one: [],
        has_and_belongs_to_many: []
      }

      model.reflect_on_all_associations.each do |assoc|
        association_info = {
          name: assoc.name.to_s,
          class_name: assoc.class_name,
          foreign_key: assoc.foreign_key&.to_s,
          primary_key: assoc.association_primary_key&.to_s
        }
        
        case assoc.macro
        when :belongs_to
          associations[:belongs_to] << association_info
        when :has_many
          associations[:has_many] << association_info
        when :has_one
          associations[:has_one] << association_info
        when :has_and_belongs_to_many
          associations[:has_and_belongs_to_many] << association_info
        end
      end

      associations
    end

    def extract_validations(model)
      validations = []
      
      model.validators.each do |validator|
        validator.attributes.each do |attribute|
          validation_info = {
            attribute: attribute.to_s,
            type: validator.class.name.demodulize.underscore.gsub(/_validator$/, ''),
            options: validator.options.except(:class)
          }
          validations << validation_info
        end
      end

      validations
    end

    def generate_uuid
      SecureRandom.uuid
    end

    def write_to_jsonl(models_data)
      File.open(output_file, "w") do |file|
        models_data.each do |model_data|
          file.puts(JSON.generate(model_data))
        end
      end
    end
  end
end

