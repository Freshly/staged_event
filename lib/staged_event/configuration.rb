# frozen_string_literal: true

require "directive"

module StagedEvent
  module Configuration
    extend Directive

    configuration_options do
      nested :google_pubsub do
        option :credentials
        option :topic_map
        option :subscription_ids
      end

      nested :publisher do
        option :batch_size
      end

      nested :subscriber do
        option :event_received_callback
      end
    end
  end
end
