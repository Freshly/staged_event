# frozen_string_literal: true

require "google/cloud/pubsub"

module StagedEvent
  module Publisher
    class GooglePubSub < Base
      def publish(model)
        topic_id = topic_map.fetch(model.topic, topic_map.values.first)
        google_topic = google_pubsub.topic(topic_id, skip_lookup: true)

        # https://github.com/googleapis/google-cloud-ruby/blob/720d14d3641a60c0fab0bf8519bdd730a753a897/google-cloud-pubsub/lib/google/cloud/pubsub/topic.rb#L655
        google_topic.publish(model.data)
      end

      private

      def google_pubsub
        @google_pubsub ||= Google::Cloud::PubSub.new(
          project_id: Configuration.config.google_pubsub.project_id,
          credentials: Configuration.config.google_pubsub.credentials,
        )
      end

      def topic_map
        Configuration.config.google_pubsub.topic_map
      end
    end
  end
end
