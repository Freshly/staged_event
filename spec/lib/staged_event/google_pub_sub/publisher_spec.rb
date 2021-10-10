# frozen_string_literal: true

RSpec.describe StagedEvent::GooglePubSub::Publisher do
  let(:instance) { described_class.new }
  let(:event) do
    StagedEvent::Model.new(
      topic: event_topic,
      data: Faker::Alphanumeric.alphanumeric,
    )
  end
  let(:event_topic) { default_topic }
  let(:default_topic) { Faker::Lorem.word }
  let(:alternate_topic) { Faker::Lorem.word }
  let(:topic_map) do
    {
      default_topic => Faker::Lorem.word,
      alternate_topic => Faker::Lorem.word,
    }
  end
  let(:google_pubsub_project) { instance_double(Google::Cloud::PubSub::Project) }

  before do
    allow(StagedEvent::GooglePubSub::Helper).to receive(:new_google_pubsub).and_return(google_pubsub_project)
  end

  describe "#initialize" do
    subject { -> { instance } }

    context "when the topic map is not a hash" do
      let(:topic_map) { nil }

      it { is_expected.to raise_error(ArgumentError) }
    end

    context "when the topic map is empty" do
      let(:topic_map) { {} }

      it { is_expected.to raise_error(ArgumentError) }
    end
  end

  describe "#publish" do
    subject(:publish) { instance.publish(event) }

    let(:google_pubsub_topic) { instance_double(Google::Cloud::PubSub::Topic) }
    let(:expected_topic_id) { topic_map[default_topic] }

    before do
      allow(StagedEvent::Configuration).to receive_message_chain(:config, :google_pubsub, :topic_map).and_return(topic_map)
      allow(google_pubsub_project).to receive(:topic).and_return(google_pubsub_topic)
      allow(google_pubsub_topic).to receive(:publish)
    end


    it "publishes the event" do
      publish
      expect(google_pubsub_topic).to have_received(:publish).with(event.data)
    end

    shared_examples_for "it selects the topic" do
      it "specifies the correct google topic id based on the event's 'topic' attribute" do
        publish
        expect(google_pubsub_project).to have_received(:topic).with(expected_topic_id, skip_lookup: true)
      end
    end

    it_behaves_like "it selects the topic"

    context "when the event does not specify a topic" do
      let(:event_topic) { nil }

      it_behaves_like "it selects the topic"
    end

    context "when the event specifies an alternate topic" do
      let(:event_topic) { alternate_topic }
      let(:expected_topic_id) { topic_map[alternate_topic] }

      it_behaves_like "it selects the topic"
    end

    context "when the event specifies a topic not found in the topic_map" do
      let(:event_topic) { Faker::Alphanumeric.alphanumeric }

      it "raises a KeyError" do
        expect { publish }.to raise_error(KeyError)
      end
    end
  end
end
