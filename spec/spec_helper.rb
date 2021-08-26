# frozen_string_literal: true

require 'faker'
require 'staged_event'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :staged_events, id: :uuid do |t|
    t.string :topic
    t.binary :data
    t.datetime :created_at, null: false
  end
end
