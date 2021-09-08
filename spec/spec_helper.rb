# frozen_string_literal: true

require "byebug"
require "database_cleaner"
require "faker"
require "sqlite3"
require "active_support"
require "active_support/core_ext"
require "securerandom"

require "staged_event"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:",
)

ActiveRecord::Schema.define do
  create_table :staged_events, id: false do |t|
    t.string :id, primary: true
    t.string :topic
    t.binary :data
    t.datetime :created_at, null: false
  end
end

module StagedEvent
  class Model < ActiveRecord::Base
    self.primary_key = "id"

    before_create -> { self.id = SecureRandom.uuid }
  end
end
