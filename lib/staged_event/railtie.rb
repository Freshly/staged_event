# frozen_string_literal: true

require "rails/railtie"

module Labyrinth
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/publisher.rake"
    end
  end
end
