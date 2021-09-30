namespace :staged_event do
  # TODO: move this to the gem via railtie
  task :process => :environment do
    StagedEvent::PublisherProcess.new(StagedEvent::Publisher::GooglePubSub.new).run
  end
end
