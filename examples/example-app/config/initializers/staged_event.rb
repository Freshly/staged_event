# frozen_string_literal: true

StagedEvent::Configuration.configure do |config|
  config.google_pubsub do |google_pubsub|
    # Identifier for a Pub/Sub project
    google_pubsub.project_id = ENV.fetch("GOOGLE_PROJECT_ID")
    # The contents of the Pub/Sub keyfile as a Hash
    google_pubsub.credentials = {}

    # This specifies the mapping between the "topic" values stored on events in
    # the database, and the associated Pub/Sub topic id. This level of indirection
    # lets you use arbitrary topic names in your application code instead of being
    # tied to names stored in a third-party infrastructure.
    # The first entry in the map is used as the default for when the event does
    # not specify a topic.
    google_pubsub.topic_map = {
      default: ENV.fetch("DEFAULT_PUBSUB_TOPIC"),
    }
  end
end
