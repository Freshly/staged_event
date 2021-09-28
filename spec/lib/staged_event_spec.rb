# frozen_string_literal: true

RSpec.describe StagedEvent do
  describe ".from_proto" do
    subject { described_class.from_proto(proto, **options) }

    let(:proto) { double }
    let(:options) { { topic: [ nil, Faker::Lorem.word ].sample } }
    let(:proto_type_url) { Faker::Alphanumeric.alphanumeric }
    let(:proto_value) { Faker::Alphanumeric.alphanumeric }
    let(:envelope) { instance_double(described_class::EventEnvelope) }
    let(:expected_uuid) { Faker::Alphanumeric.alphanumeric }
    let(:expected_envelope_params) do
      {
        event: {
          type_url: proto_type_url,
          value: proto_value,
        },
        uuid: expected_uuid,
      }
    end
    let(:serialized_proto) { Faker::Alphanumeric.alphanumeric }

    before do
      allow(SecureRandom).to receive(:uuid).and_return(expected_uuid)
      allow(proto).to receive_message_chain(:class, :descriptor, :name).and_return(proto_type_url)
      allow(proto).to receive_message_chain(:class, :encode).with(proto).and_return(proto_value)
      allow(described_class::EventEnvelope).to receive(:new).with(expected_envelope_params).and_return(envelope)
      allow(described_class::EventEnvelope).to receive(:encode).with(envelope).and_return(serialized_proto)
    end

    it { is_expected.to be_instance_of(described_class::Model) }
    it { is_expected.to have_attributes(id: expected_uuid, data: serialized_proto, topic: options[:topic]) }
  end
end
