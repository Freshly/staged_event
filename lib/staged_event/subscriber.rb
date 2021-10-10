# frozen_string_literal: true

module StagedEvent
  class Subscriber
    def receive_events
      raise StandardError, "You must implement the receive_events method"
    end
  end
end
