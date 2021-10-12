namespace :staged_event do
  desc "Run the staged_event subscriber process"
  task :subscriber => :environment do |task, args|
    StagedEvent::SubscriberProcess.new(StagedEvent::GooglePubSub::Subscriber.new).run
  end
end
