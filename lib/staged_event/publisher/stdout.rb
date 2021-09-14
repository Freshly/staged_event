# frozen_string_literal: true

require "logger"

module StagedEvent
  module Publisher
    class Stdout < Base
      def publish(model)
        logger.info("#{self.class} published to topic '#{model.topic}'") do
          model.data
        end
      end

      private

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end
