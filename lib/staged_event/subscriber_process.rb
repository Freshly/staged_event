# frozen_string_literal: true

module StagedEvent
  class SubscriberProcess
    include Technologic

    def initialize(subscriber)
      @subscriber = subscriber
    end

    def run
      subscriber.receive_events
    rescue StandardError => exception
      error :subscriber_main_loop_failed, exception: exception.message
      retry
    end

    private

    attr_reader :subscriber
  end
end
