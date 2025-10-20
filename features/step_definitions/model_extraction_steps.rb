# frozen_string_literal: true

Given("a Rails application with models") do
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
    validates :title, presence: true
  end)
end

Given("a Rails application with {int} models") do |count|
  # Create test tables based on count
  ActiveRecord::Schema.define do
    create_table :users, force: true do |t|
      t.string :email
      t.timestamps
    end

    create_table :posts, force: true do |t|
      t.string :title
      t.timestamps
    end if count >= 2
  end

  # Define models
  stub_const("User", Class.new(ActiveRecord::Base))
  stub_const("Post", Class.new(ActiveRecord::Base)) if count >= 2
end

When("I run the model extraction") do
  @extractor = AppwrapModels::ModelExtractor.new(
    rails_root: @test_dir,
    output_dir: "appwrap"
  )
  @extraction_count = @extractor.extract
end

Then("the appwrap directory should be created") do
  expect(File.directory?(@output_dir)).to be true
end

Then("the routes.jsonl file should exist") do
  expect(File.exist?(@output_file)).to be true
end

Then("the file should contain valid JSONL data") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    expect { JSON.parse(line) }.not_to raise_error
  end
end

Then("each model should have a unique UUID") do
  lines = File.readlines(@output_file)
  uuids = lines.map { |line| JSON.parse(line)["uuid"] }
  expect(uuids.uniq.size).to eq(uuids.size)
end

Then("the UUID should be in valid format") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["uuid"]).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
  end
end

Then("each model should have a name") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["name"]).not_to be_nil
    expect(data["name"]).to be_a(String)
  end
end

Then("each model should have a table_name") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["table_name"]).not_to be_nil
    expect(data["table_name"]).to be_a(String)
  end
end

Then("each model should have columns information") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["columns"]).not_to be_nil
    expect(data["columns"]).to be_an(Array)
  end
end

Then("each model should have associations information") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["associations"]).not_to be_nil
    expect(data["associations"]).to be_a(Hash)
  end
end

Then("each model should have validations information") do
  lines = File.readlines(@output_file)
  lines.each do |line|
    data = JSON.parse(line)
    expect(data["validations"]).not_to be_nil
    expect(data["validations"]).to be_an(Array)
  end
end

Then("the routes.jsonl file should contain {int} lines") do |expected_lines|
  lines = File.readlines(@output_file)
  expect(lines.size).to eq(expected_lines)
end

Then("each line should represent a different model") do
  lines = File.readlines(@output_file)
  model_names = lines.map { |line| JSON.parse(line)["name"] }
  expect(model_names.uniq.size).to eq(model_names.size)
end

