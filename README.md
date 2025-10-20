# AppwrapModels

AppwrapModels is a Ruby gem that extracts model information from Rails applications and writes them to a structured JSONL format with assigned UUIDs. This gem is designed to help developers analyze, document, and understand the data models in their Rails applications.

## Features

The gem provides comprehensive model extraction capabilities that capture the essential structure and relationships within your Rails application. It automatically scans all ActiveRecord models and extracts detailed information including model names, table names, column definitions with their types and constraints, associations between models, and validation rules. Each extracted model is assigned a unique UUID for identification purposes.

All extracted data is written exclusively to the `appwrap` folder in your Rails application root directory, ensuring that the gem does not interfere with your existing project structure. The output is generated in JSONL (JSON Lines) format, where each line represents a complete JSON object for a single model, making it easy to process programmatically or analyze with standard text processing tools.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'appwrap_models'
```

Then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install appwrap_models
```

## Usage

Once the gem is installed in your Rails application, you can extract model information using the provided rake task:

```bash
rake appwrap:models:extract
```

This command will scan all models in your Rails application and generate a file at `appwrap/routes.jsonl` containing the extracted information.

## Output Format

The gem generates a JSONL file where each line contains a JSON object representing one model. The structure of each model object includes the following fields:

- **uuid**: A unique identifier (UUID v4) assigned to the model
- **name**: The class name of the model
- **table_name**: The database table name associated with the model
- **columns**: An array of column definitions, each containing:
  - name: Column name
  - type: Ruby type (string, integer, datetime, etc.)
  - sql_type: Database-specific SQL type
  - null: Whether the column allows NULL values
  - default: Default value for the column
  - primary: Whether this is the primary key column
- **associations**: An object containing arrays for different association types:
  - belongs_to: Array of belongs_to associations
  - has_many: Array of has_many associations
  - has_one: Array of has_one associations
  - has_and_belongs_to_many: Array of HABTM associations
- **validations**: An array of validation rules applied to the model

### Example Output

```json
{"uuid":"550e8400-e29b-41d4-a716-446655440000","name":"User","table_name":"users","columns":[{"name":"id","type":"integer","sql_type":"INTEGER","null":false,"default":null,"primary":true},{"name":"email","type":"string","sql_type":"varchar","null":false,"default":null,"primary":false},{"name":"name","type":"string","sql_type":"varchar","null":true,"default":null,"primary":false}],"associations":{"belongs_to":[],"has_many":[{"name":"posts","class_name":"Post","foreign_key":"user_id","primary_key":"id"}],"has_one":[],"has_and_belongs_to_many":[]},"validations":[{"attribute":"email","type":"presence","options":{}},{"attribute":"email","type":"uniqueness","options":{}}]}
```

## Requirements

This gem requires Ruby version 3.3.6 or higher and Rails version 6.0 or higher. It is designed to work with any Rails application that uses ActiveRecord as its ORM.

## Development

After checking out the repository, run `bundle install` to install dependencies. Then, run `rake spec` to run the RSpec tests and `rake cucumber` to run the Cucumber feature tests. You can also run `rake` to run both test suites.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to rubygems.org.

## Testing

The gem includes comprehensive test coverage using both RSpec and Cucumber:

### RSpec Tests

Unit tests are provided for the core functionality of the gem. Run them with:

```bash
rake spec
```

### Cucumber Tests

Behavior-driven development tests are included to verify the extraction functionality from a user perspective. Run them with:

```bash
rake cucumber
```

### Running All Tests

To run both RSpec and Cucumber tests:

```bash
rake
```

## Architecture

The gem is structured around three main components:

1. **ModelExtractor**: The core class responsible for scanning Rails models and extracting their information. It handles the discovery of ActiveRecord models, extraction of metadata, UUID generation, and writing to JSONL format.

2. **Railtie**: Provides Rails integration by registering the rake tasks with the Rails application. This ensures that the gem's functionality is automatically available when included in a Rails project.

3. **Rake Task**: Defines the `appwrap:models:extract` task that serves as the user interface for triggering model extraction.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appwrap/appwrap_models. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the code of conduct.

## License

The gem is available as open source under the terms of the MIT License. See the LICENSE.txt file for details.

## Code of Conduct

Everyone interacting in the AppwrapModels project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the code of conduct.

# appwrap_testrunner
