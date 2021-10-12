# frozen_string_literal: true

module StagedEvent
  class Publisher
    def publish(_model)
      raise StandardError, "You must implement the publish method"
    end
  end
end
