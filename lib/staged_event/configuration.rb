# frozen_string_literal: true

module StagedEvent
  module Configuration
    extend Directive

    configuration_options do
      nested :google_pubsub do
        option :project_id
        option :credentials
        option :topic_map
      end
    end
  end
end
