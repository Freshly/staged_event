# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module StagedEvent
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    class << self
      delegate :next_migration_number, to: ActiveRecord::Generators::Base
    end

    source_paths << File.join(File.dirname(__FILE__), "templates")

    # Generates monolithic migration file that contains all database changes.
    def create_migration_file
      migration_template "create_staged_events.rb.erb", "db/migrate/create_staged_events.rb"
    end
  end
end
