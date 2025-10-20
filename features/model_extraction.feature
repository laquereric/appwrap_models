Feature: Model Extraction
  As a Rails developer
  I want to extract model information from my Rails application
  So that I can have a structured representation of my models in JSONL format

  Background:
    Given a Rails application with models

  Scenario: Extract models to JSONL file
    When I run the model extraction
    Then the appwrap directory should be created
    And the routes.jsonl file should exist
    And the file should contain valid JSONL data

  Scenario: Assign UUIDs to models
    When I run the model extraction
    Then each model should have a unique UUID
    And the UUID should be in valid format

  Scenario: Extract model attributes
    When I run the model extraction
    Then each model should have a name
    And each model should have a table_name
    And each model should have columns information
    And each model should have associations information
    And each model should have validations information

  Scenario: Extract multiple models
    Given a Rails application with 2 models
    When I run the model extraction
    Then the routes.jsonl file should contain 2 lines
    And each line should represent a different model

