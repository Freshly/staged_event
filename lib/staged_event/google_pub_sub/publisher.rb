# frozen_string_literal: true

module StagedEvent
  module GooglePubSub
    class Publisher < StagedEvent::Publisher
      def initialize
        @google_pubsub = Helper.new_google_pubsub

        raise ArgumentError, "topic_map must be initialized" unless topic_map.is_a?(Hash) && topic_map.any?
      end

      def publish(model)
        topic_name = model.topic || topic_map.keys.first
        topic_id = topic_map.fetch(topic_name)
        google_topic = google_pubsub.topic(topic_id, skip_lookup: true)

        # https://github.com/googleapis/google-cloud-ruby/blob/720d14d3641a60c0fab0bf8519bdd730a753a897/google-cloud-pubsub/lib/google/cloud/pubsub/topic.rb#L655
        google_topic.publish(model.data)
      end

      private

      attr_reader :google_pubsub

      def topic_map
        Configuration.config.google_pubsub.topic_map
      end
    end
  end
end
