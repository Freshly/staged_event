# frozen_string_literal: true

require "directive"

module StagedEvent
  module Configuration
    extend Directive

    configuration_options do
      nested :google_pubsub do
        option :project_id
        option :credentials
        option :topic_map
      end

      nested :publisher do
        option :batch_size
      end
    end
  end
end
