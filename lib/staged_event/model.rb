# frozen_string_literal: true

module StagedEvent
  class Model < ActiveRecord::Base
    self.table_name = :staged_events
  end
end
