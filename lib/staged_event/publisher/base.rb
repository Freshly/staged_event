# frozen_string_literal: true

module StagedEvent
  module Publisher
    class PublishFailedError < StandardError; end

    class Base
      def publish(_model)
        raise StandardError, "You must implement the publish method"
      end
    end
  end
end
