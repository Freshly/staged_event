# frozen_string_literal: true

module StagedEvent
  module Subscriber
    class Base
      def receive_events
        raise StandardError, "You must implement the receive_events method"
      end
    end
  end
end
