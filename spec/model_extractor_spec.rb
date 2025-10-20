# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "json"
require "tmpdir"

RSpec.describe AppwrapModels::ModelExtractor do
  let(:test_dir) { Dir.mktmpdir }
  let(:output_dir) { File.join(test_dir, "appwrap") }
  let(:output_file) { File.join(output_dir, "routes.jsonl") }

  # Mock Rails
  before do
    stub_const("Rails", Class.new do
      def self.root
        @root ||= Pathname.new(test_dir)
      end

      def self.application
        @application ||= Class.new do
          def self.eager_load!
            # No-op for testing
          end
        end.new
      end
    end)

    # Create test models
    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:"
    )

    # Create test tables
    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string :email, null: false
        t.string :name
        t.timestamps
      end

      create_table :posts, force: true do |t|
        t.integer :user_id
        t.string :title
        t.text :content
        t.timestamps
      end
    end

    # Define test models
    stub_const("User", Class.new(ActiveRecord::Base) do
      has_many :posts
      validates :email, presence: true
    end)

    stub_const("Post", Class.new(ActiveRecord::Base) do
      belongs_to :user
      validates :title, presence: true, length: { minimum: 5 }
    end)
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  describe "#initialize" do
    it "sets rails_root and output_dir" do
      extractor = described_class.new(rails_root: test_dir, output_dir: "appwrap")
      expect(extractor.rails_root).to eq(test_dir)
      expect(extractor.output_dir).to eq(output_dir)
    end
  end

  describe "#extract" do
    let(:extractor) { described_class.new(rails_root: test_dir, output_dir: "appwrap") }

    it "creates the output directory if it doesn't exist" do
      expect(File.directory?(output_dir)).to be false
      extractor.extract
      expect(File.directory?(output_dir)).to be true
    end

    it "creates the routes.jsonl file" do
      extractor.extract
      expect(File.exist?(output_file)).to be true
    end

    it "returns the number of extracted models" do
      count = extractor.extract
      expect(count).to eq(2) # User and Post
    end

    it "writes valid JSONL format" do
      extractor.extract
      lines = File.readlines(output_file)
      
      expect(lines.size).to eq(2)
      
      lines.each do |line|
        expect { JSON.parse(line) }.not_to raise_error
      end
    end

    it "includes UUID for each model" do
      extractor.extract
      lines = File.readlines(output_file)
      
      lines.each do |line|
        data = JSON.parse(line)
        expect(data["uuid"]).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
      end
    end

    it "extracts model names" do
      extractor.extract
      lines = File.readlines(output_file)
      models = lines.map { |line| JSON.parse(line)["name"] }
      
      expect(models).to include("User", "Post")
    end

    it "extracts table names" do
      extractor.extract
      lines = File.readlines(output_file)
      
      user_data = lines.map { |line| JSON.parse(line) }.find { |d| d["name"] == "User" }
      expect(user_data["table_name"]).to eq("users")
    end

    it "extracts columns with details" do
      extractor.extract
      lines = File.readlines(output_file)
      
      user_data = lines.map { |line| JSON.parse(line) }.find { |d| d["name"] == "User" }
      columns = user_data["columns"]
      
      expect(columns).to be_an(Array)
      expect(columns.size).to be > 0
      
      email_column = columns.find { |c| c["name"] == "email" }
      expect(email_column).not_to be_nil
      expect(email_column["type"]).to eq("string")
      expect(email_column["null"]).to be false
    end

    it "extracts associations" do
      extractor.extract
      lines = File.readlines(output_file)
      
      user_data = lines.map { |line| JSON.parse(line) }.find { |d| d["name"] == "User" }
      associations = user_data["associations"]
      
      expect(associations["has_many"]).to be_an(Array)
      expect(associations["has_many"].first["name"]).to eq("posts")
      
      post_data = lines.map { |line| JSON.parse(line) }.find { |d| d["name"] == "Post" }
      post_associations = post_data["associations"]
      
      expect(post_associations["belongs_to"]).to be_an(Array)
      expect(post_associations["belongs_to"].first["name"]).to eq("user")
    end

    it "extracts validations" do
      extractor.extract
      lines = File.readlines(output_file)
      
      user_data = lines.map { |line| JSON.parse(line) }.find { |d| d["name"] == "User" }
      validations = user_data["validations"]
      
      expect(validations).to be_an(Array)
      expect(validations.size).to be > 0
      
      email_validation = validations.find { |v| v["attribute"] == "email" }
      expect(email_validation).not_to be_nil
      expect(email_validation["type"]).to eq("presence")
    end
  end
end

