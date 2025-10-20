# frozen_string_literal: true

require "spec_helper"

RSpec.describe AppwrapModels do
  it "has a version number" do
    expect(AppwrapModels::VERSION).not_to be nil
  end

  it "has the correct version format" do
    expect(AppwrapModels::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end

  it "defines an Error class" do
    expect(AppwrapModels::Error).to be < StandardError
  end
end

