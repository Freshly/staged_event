# frozen_string_literal: true

module StagedEvent
  class PublisherProcess
    include Technologic

    def initialize(publisher)
      @publisher = publisher
      @backoff_timer = Publisher::BackoffTimer.new
    end

    def run
      loop do
        sleep(backoff_timer.value)
        publish_next_batch
      end
    rescue StandardError => exception
      error :publish_failed, exception: exception.message
      backoff_timer.increment
      retry
    end

    private

    attr_reader :publisher, :backoff_timer

    def publish_next_batch
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          events = Model.order(:created_at).limit(batch_size).lock("FOR UPDATE SKIP LOCKED")
          if events.any?
            events.each do |event|
              publisher.publish(event)
            end
            events.destroy_all
            backoff_timer.reset
          else
            backoff_timer.increment
          end
        end
      end
    end

    def batch_size
      Configuration.config.publisher.batch_size
    end
  end
end
