namespace :staged_event do
  desc "Run the staged_event publisher process"
  task :publisher => :environment do
    StagedEvent::PublisherProcess.new(StagedEvent::GooglePubSub::Publisher.new).run
  end
end
