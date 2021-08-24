# frozen_string_literal: true

require 'active_record'
require_relative 'staged_event/message_envelope_pb'
require_relative 'staged_event/model'
require_relative 'staged_event/version'

module StagedEvent
  def self.from_proto(proto, **kwargs)
    envelope = MessageEnvelope.new(
      message: {
        type_url: proto.class.descriptor.name,
        value: proto.class.encode(proto)
      }
    )

    data = MessageEnvelope.encode(envelope)
    topic = kwargs.fetch(:topic, nil)

    Model.new(data: data, topic: topic)
  end
end
