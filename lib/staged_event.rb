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

    serialized_proto = MessageEnvelope.encode(envelope)

    Model.new(data: serialized_proto, topic: kwargs.fetch(:topic, nil))
  end
end
