# frozen_string_literal: true

module StagedEvent
  module Publisher
    class BackoffTimer
      INCREMENTS_BEFORE_BACKOFF = 5
      MAX_VALUE = 25

      def initialize
        reset
      end

      def increment
        @backoff_count += 1
      end

      def reset
        @backoff_count = 0
      end

      def value
        # returns 1 until the timer has been incremented n times, after which it
        # returns n^2 (until reaching a set maximum)
        backoff_time = [ 1, backoff_count - INCREMENTS_BEFORE_BACKOFF + 1 ].max**2
        [ backoff_time, MAX_VALUE ].min
      end

      private

      attr_accessor :backoff_count
    end
  end
end
