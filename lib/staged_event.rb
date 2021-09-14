# frozen_string_literal: true

require_relative "staged_event/backoff_timer"
require_relative "staged_event/configuration"
require_relative "staged_event/message_envelope_pb"
require_relative "staged_event/model"
require_relative "staged_event/publisher/base"
require_relative "staged_event/publisher/google_pub_sub"
require_relative "staged_event/publisher/stdout"
require_relative "staged_event/publisher_process"
require_relative "staged_event/version"

require_relative "staged_event/railtie" if defined?(Rails)

module StagedEvent
  class << self
    def from_proto(proto, **kwargs)
      envelope = MessageEnvelope.new(
        message: {
          type_url: proto.class.descriptor.name,
          value: proto.class.encode(proto),
        },
      )

      data = MessageEnvelope.encode(envelope)
      topic = kwargs.fetch(:topic, nil)

      Model.new(data: data, topic: topic)
    end
  end
end
