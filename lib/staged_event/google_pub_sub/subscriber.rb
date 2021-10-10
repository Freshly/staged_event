# frozen_string_literal: true

module StagedEvent
  module GooglePubSub
    class Subscriber < StagedEvent::Subscriber
      include Technologic

      def initialize
        @google_pubsub = Helper.new_google_pubsub

        raise ArgumentError, "event_received_callback is undefined" unless event_received_callback.respond_to?(:call)
      end

      def receive_events
        threads = []

        subscription_ids.each do |subscription_id|
          threads << Thread.new do
            receive_events_from_subscription(subscription_id)
          end
        end

        threads.each(&:join)
      end

      def receive_events_from_subscription(subscription_id)
        subscription = google_pubsub.subscription(subscription_id)

        loop do
          received_messages = subscription.pull(immediate: false)
          received_messages.each do |received_message|
            event_received_callback.call(received_message.data)
            received_message.acknowledge!
          end
        end
      end

      # TODO: Google pub/sub has built-in multi-threaded listeners but I haven't
      # been able to successfully receive any messages using that API yet.
      #
      # def receive_events_from_subscription(subscription_id)
      #   subscription = google_pubsub.subscription(subscription_id)
      #   subscriber = subscription.listen(threads: { callback: 5 }) do |message|
      #     event_received_callback.call(message.data)
      #     message.acknowledge!
      #   end
      #
      #   # Start background threads that will call the block passed to listen.
      #   subscriber.start
      #
      #   # Block, letting processing threads continue in the background
      #   sleep
      # end

      private

      attr_reader :google_pubsub

      def subscription_ids
        Configuration.config.google_pubsub.subscription_ids
      end

      def event_received_callback
        Configuration.config.subscriber.event_received_callback
      end
    end
  end
end
