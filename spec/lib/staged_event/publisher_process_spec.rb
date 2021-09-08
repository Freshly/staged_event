# frozen_string_literal: true

RSpec.describe StagedEvent::PublisherProcess do
  describe "#run" do
    subject(:run) { instance.run }

    let(:instance) { described_class.new(publisher) }
    let(:publisher) { instance_double(StagedEvent::Publisher::Base) }
    let(:backoff_timer) do
      instance_double(
        StagedEvent::Publisher::BackoffTimer, {
          reset: nil,
          increment: nil,
          value: backoff_timer_value,
        }
      )
    end
    let(:backoff_timer_value) { rand(1..100) }
    let(:batch_size) { rand(2..5) }

    before do
      allow(StagedEvent::Configuration).to receive_message_chain(:config, :publisher, :batch_size).and_return(batch_size)
      allow(StagedEvent::Publisher::BackoffTimer).to receive(:new).and_return(backoff_timer)
      allow(publisher).to receive(:publish)
      allow(instance).to receive(:loop).and_yield
      allow(instance).to receive(:sleep)
    end

    context "when there are NO events to publish" do
      before { run }

      it "sleeps according to the backoff timer" do
        expect(instance).to have_received(:sleep).with(backoff_timer_value)
      end

      it "increments the backoff timer" do
        expect(backoff_timer).to have_received(:increment)
      end

      it "does not call publish" do
        expect(publisher).not_to have_received(:publish)
      end
    end

    context "when there are events to publish" do
      let!(:all_events) do
        StagedEvent::Model.create(
          Array.new(batch_size + rand(1..5)) do
            { topic: Faker::Lorem.word, data: Faker::Alphanumeric.alphanumeric }
          end,
        )
      end
      let(:events_published) { all_events.first(batch_size) }
      let(:events_remaining) { all_events - events_published }

      context "when publishing is successful" do
        before { run }

        it "sleeps according to the backoff timer" do
          expect(instance).to have_received(:sleep).with(backoff_timer_value)
        end

        it "invokes the publisher for each event" do
          events_published.each do |event|
            expect(publisher).to have_received(:publish).with(event)
          end
        end

        it "destroys all the published events" do
          expect(StagedEvent::Model.count).to eq(events_remaining.size)
          expect(StagedEvent::Model.ids).to match_array(events_remaining.map(&:id))
        end

        it "resets the backoff timer" do
          expect(backoff_timer).to have_received(:reset)
        end
      end

      context "when publishing raises an error" do
        before do
          publish_count = 0
          allow(publisher).to receive(:publish) do
            publish_count += 1
            raise StagedEvent::Publisher::PublishFailedError if publish_count == 1
          end
          run
        end

        it "increments the backoff timer" do
          expect(backoff_timer).to have_received(:increment)
        end

        it "retries the loop" do
          expect(instance).to have_received(:sleep).twice
        end
      end
    end
  end
end
