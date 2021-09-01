# frozen_string_literal: true

require_relative "lib/staged_event/version"

Gem::Specification.new do |spec|
  spec.name        = "staged_event"
  spec.version     = StagedEvent::VERSION
  spec.summary     = "StagedEvent"
  spec.description = "A transactional outbox implementation for Ruby/ActiveRecord"
  spec.authors     = ["Andrew Cross"]
  spec.email       = "andrew.cross@freshly.com"
  spec.files       = Dir["{bin,lib}/**/*", "README.md"]
  spec.homepage    = "https://github.com/Freshly/staged_event"
  spec.license     = "MIT"

  spec.add_runtime_dependency "activerecord", ">= 6.0.0"
  spec.add_runtime_dependency "directive", ">= 0.23.1.1"
  spec.add_runtime_dependency "google-protobuf", ">= 3.8.0", "< 4.0.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
end

