# frozen_string_literal: true

module StagedEvent
  module GooglePubSub
    class Helper
      class << self
        def new_google_pubsub
          credentials = Configuration.config.google_pubsub.credentials.to_h
          project_id = credentials[:project_id]

          Google::Cloud::PubSub.new(
            project_id: project_id,
            credentials: credentials,
          )
        end
      end
    end
  end
end
