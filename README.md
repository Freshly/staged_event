# StagedEvent

StagedEvent is a Ruby implementation of the [transactional outbox](https://microservices.io/patterns/data/transactional-outbox.html) architectural pattern.

This gem is relevant for any process that wants to publish events to a set of subscribers. It automatically saves outgoing events as records in a database table, from which a separate background process reads, publishes, and (once publishing is confirmed) deletes them. StagedEvent also provides a listener to subscribe to and receive these events from other processes.

Staging events this way allows them to be persisted within the same database transaction as associated domain-specific records, guaranteeing at-least-once delivery and eventual consistency.

For now, StagedEvent makes the following assumptions:
- Events are defined as protobufs (and you have generated Ruby classes for them)
- [Google Pub/Sub](https://cloud.google.com/pubsub/) is the underyling messaging infrastructure
- You're using a Postgres database (>= version 9.5) via ActiveRecord.


### Regenerating Ruby from protobufs

StagedEvent uses a one-off protobuf definition to serialize and deserialize events that are defined as protobufs. In case it becomes necessary to recreate the auto-generated ruby, the command for that (from the repository root) is:

protoc --ruby_out=./ "./lib/staged_event/message_envelope.proto"
