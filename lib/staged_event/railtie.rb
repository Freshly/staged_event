# frozen_string_literal: true

require "rails/railtie"

module Labyrinth
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/publisher.rake"
      load "tasks/subscriber.rake"
    end
  end
end
