# frozen_string_literal: true

require "active_record"

module StagedEvent
  class Model < ActiveRecord::Base
    self.table_name = :staged_events
  end
end
