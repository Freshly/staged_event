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

  spec.add_dependency "activerecord", ">= 6.0.0"
end

