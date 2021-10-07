# frozen_string_literal: true

RSpec.describe StagedEvent::Subscriber::GooglePubSub do
  let(:instance) { described_class.new }
  let(:topic) { Faker::Lorem.word }
  let(:subscriber_config) do
    OpenStruct.new(
      event_received_callback: event_received_callback,
    )
  end
  let(:event_received_callback) { -> (serialized_data) {} }
  let(:subscription_ids) do
    Array.new(rand(1..3)) { Faker::Alphanumeric.alphanumeric }
  end
  let(:google_pubsub_config) do
    OpenStruct.new(
      subscription_ids: subscription_ids,
      project_id: Faker::Alphanumeric.alphanumeric,
      credentials: Faker::Alphanumeric.alphanumeric,
    )
  end

  before do
    allow(StagedEvent::Configuration).to receive_message_chain(:config, :subscriber).and_return(subscriber_config)
    allow(StagedEvent::Configuration).to receive_message_chain(:config, :google_pubsub).and_return(google_pubsub_config)
  end

  describe "#initialize" do
    subject { -> { instance } }

    context "when event_received_callback is not defined" do
      let(:event_received_callback) { nil }

      it { is_expected.to raise_error(ArgumentError) }
    end
  end

  describe "#receive_events" do
    subject(:call) { instance.receive_events }

    let(:expected_threads) { [] }

    before do
      allow(Thread).to receive(:new) { instance_double(Thread, join: nil).tap {|t| expected_threads << t } }.and_yield
      allow(instance).to receive(:receive_events_from_subscription)
      call
    end

    it "calls receive_events_from_subscription for each subscription id" do
      subscription_ids.each do |subscription_id|
        expect(instance).to have_received(:receive_events_from_subscription).with(subscription_id)
      end
    end

    it "calls join on each thread" do
      expected_threads.each do |thread|
        expect(thread).to have_received(:join)
      end
    end
  end

  describe "#receive_events_from_subscription" do
    subject(:call) { instance.receive_events_from_subscription(subscription_id) }

    let(:subscription_id) { subscription_ids.sample }
    let(:google_pubsub_project) { instance_double(Google::Cloud::PubSub::Project) }
    let(:google_pubsub_subscription) { instance_double(Google::Cloud::PubSub::Subscription ) }
    let(:google_pubsub_received_messages) do
      Array.new(rand(1..3)) do
        instance_double(Google::Cloud::PubSub::ReceivedMessage,
          data: Faker::Alphanumeric.alphanumeric,
          acknowledge!: nil,
        )
      end
    end

    before do
      allow(Google::Cloud::PubSub).to receive(:new).and_return(google_pubsub_project)
      allow(google_pubsub_project).to receive(:subscription).with(subscription_id).and_return(google_pubsub_subscription)
      allow(google_pubsub_subscription).to receive(:pull).with(immediate: false).and_return(google_pubsub_received_messages)
      allow(instance).to receive(:loop).and_yield
      allow(event_received_callback).to receive(:call)
      call
    end

    it "acknowledges each received message" do
      google_pubsub_received_messages.each do |message|
        expect(message).to have_received(:acknowledge!)
      end
    end

    it "invokes the callback for each received message" do
      google_pubsub_received_messages.each do |message|
        expect(event_received_callback).to have_received(:call).with(message.data)
      end
    end
  end
end
