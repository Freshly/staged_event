# frozen_string_literal: true

require_relative "staged_event/backoff_timer"
require_relative "staged_event/configuration"
require_relative "staged_event/event_envelope_pb"
require_relative "staged_event/model"
require_relative "staged_event/publisher/base"
require_relative "staged_event/publisher/google_pub_sub"
require_relative "staged_event/publisher/stdout"
require_relative "staged_event/publisher_process"
require_relative "staged_event/subscriber/base"
require_relative "staged_event/subscriber/google_pub_sub"
require_relative "staged_event/subscriber_process"
require_relative "staged_event/version"

require_relative "staged_event/railtie" if defined?(Rails)

module StagedEvent
  class Error < StandardError; end

  class DeserializationError < Error; end
  class UnknownEventTypeError < Error; end

  class << self
    # Builds an ActiveRecord model from a proto object representing an event.
    # If the model is committed to the database, it will be published by the
    # publisher process.
    #
    # @param [Instance of a protobuf generated class] proto the event data to publish
    # @option kwargs [String] :topic the topic that will receive the event
    # @return [StagedEvent::Model] an ActiveRecord model ready to be saved
    def from_proto(proto, **kwargs)
      uuid = SecureRandom.uuid

      envelope = EventEnvelope.new(
        event: {
          type_url: proto.class.descriptor.name,
          value: proto.class.encode(proto),
        },
        uuid: uuid,
      )

      data = EventEnvelope.encode(envelope)
      topic = kwargs.fetch(:topic, nil)

      Model.new(id: uuid, data: data, topic: topic)
    end

    # Converts serialized event data received from a publisher into an object with
    # the event (and its metadata) in accessible form
    #
    # @param [String] serialized_data the serialized event data
    # @return [OpenStruct] an object representing the event
    def deserialize_event(serialized_data)
      envelope = EventEnvelope.decode(serialized_data)
      event_descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(envelope.event.type_url)
      raise UnknownEventTypeError if event_descriptor.blank?

      proto = event_descriptor.msgclass.decode(envelope.event.value)

      OpenStruct.new(
        id: envelope.uuid,
        data: proto,
      )
    rescue Google::Protobuf::ParseError
      raise DeserializationError
    end
  end
end
