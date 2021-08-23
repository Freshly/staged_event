# StagedEvent

StagedEvent is a Ruby implementation of the [transactional outbox](https://microservices.io/patterns/data/transactional-outbox.html) architectural pattern.

This gem is relevant for any process that wants to publish events to a set of subscribers. It automatically saves outgoing events as records in a database table, from which a separate background process reads, publishes, and (once publishing is confirmed) deletes them. StagedEvent also provides a listener to subscribe to and receive these events from other processes.

Staging events this way allows them to be persisted within the same database transaction as associated domain-specific records, guaranteeing at-least-once delivery and eventual consistency.

The implementation supports Google Pub/Sub as the publishing infrastructure, and assumes a Postgres database (>= version 9.5) accessed via ActiveRecord.
