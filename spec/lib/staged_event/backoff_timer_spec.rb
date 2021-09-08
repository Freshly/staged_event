# frozen_string_literal: true

RSpec.describe StagedEvent::BackoffTimer do
  subject(:value) { instance.value }

  let(:instance) { described_class.new }

  context "when called on a new instance" do
    it { is_expected.to eq(1) }
  end

  context "when repeatedly incremented" do
    let(:sequence) do
      Array.new(8) do
        instance.increment
        instance.value
      end
    end

    before do
      stub_const("StagedEvent::BackoffTimer::INCREMENTS_BEFORE_BACKOFF", 2)
    end

    it "returns the expected sequence" do
      expect(sequence).to eq([ 1, 1, 4, 9, 16, 25, 25, 25 ])
    end

    context "when reset is called" do
      before do
        sequence
        instance.reset
      end

      it { is_expected.to eq(1) }
    end
  end
end
