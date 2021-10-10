# frozen_string_literal: true

RSpec.describe StagedEvent::SubscriberProcess do
  describe "#run" do
    subject(:run) { instance.run }

    let(:instance) { described_class.new(subscriber) }
    let(:subscriber) { instance_double(StagedEvent::Subscriber, receive_events: nil) }

    it "calls receive_events on the subscriber" do
      run
      expect(subscriber).to have_received(:receive_events)
    end

    context "when receive_events raises an exception" do
      before do
        call_count = 0
        allow(subscriber).to receive(:receive_events) do
          call_count += 1
          raise StandardError if call_count == 1
        end
      end

      it "retries" do
        run
        expect(subscriber).to have_received(:receive_events).twice
      end
    end
  end
end
