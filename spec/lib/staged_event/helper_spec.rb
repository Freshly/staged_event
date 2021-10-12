# frozen_string_literal: true

RSpec.describe StagedEvent::GooglePubSub::Helper do
  describe ".new_google_pubsub" do
    subject(:call) { described_class.new_google_pubsub }

    let(:project_id) { Faker::Alphanumeric.alphanumeric }
    let(:credentials) do
      {
        project_id: project_id,
        foo: Faker::Lorem.word,
      }
    end
    let(:google_pubsub) { instance_double(Google::Cloud::PubSub) }

    before do
      allow(StagedEvent::Configuration).to receive_message_chain(:config, :google_pubsub, :credentials).and_return(credentials)
      allow(Google::Cloud::PubSub).to receive(:new).and_return(google_pubsub)
    end

    it "creates a PubSub instance with the correct params" do
      expect(call).to eq(google_pubsub)
      expect(Google::Cloud::PubSub).to have_received(:new).with(
        project_id: project_id,
        credentials: credentials,
      )
    end
  end
end
