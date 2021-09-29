# frozen_string_literal: true

RSpec.describe StagedEvent do
  describe "protobuf support" do
    Google::Protobuf::DescriptorPool.generated_pool.build do
      add_file("example_event.proto", syntax: :proto3) do
        add_message "staged_event.ExampleEvent" do
          optional :foo, :string, 1
          optional :bar, :string, 2
        end
      end
    end

    let(:example_proto) do
      ExampleEvent.new(
        foo: Faker::Alphanumeric.alphanumeric,
        bar: Faker::Alphanumeric.alphanumeric,
      )
    end

    before do
      stub_const("ExampleEvent", ::Google::Protobuf::DescriptorPool.generated_pool.lookup("staged_event.ExampleEvent").msgclass)
    end

    describe ".from_proto" do
      subject { described_class.from_proto(example_proto, **options) }

      let(:options) { { topic: [ nil, Faker::Lorem.word ].sample } }
      let(:expected_data) { described_class::EventEnvelope.encode(envelope) }
      let(:envelope) do
        described_class::EventEnvelope.new(
          event: {
            type_url: ExampleEvent.descriptor.name,
            value: ExampleEvent.encode(example_proto),
          },
          uuid: expected_uuid,
        )
      end
      let(:expected_uuid) { Faker::Alphanumeric.alphanumeric }

      before do
        allow(SecureRandom).to receive(:uuid).and_return(expected_uuid)
      end

      it { is_expected.to be_instance_of(described_class::Model) }
      it { is_expected.to have_attributes(id: expected_uuid, data: expected_data, topic: options[:topic]) }
    end

    describe ".deserialize_event" do
      subject(:call) { described_class.deserialize_event(serialized_data) }

      let(:serialized_data) { model.data }
      let(:model) { described_class.from_proto(example_proto) }
      let(:expected_result) do
        OpenStruct.new(
          id: model.id,
          data: example_proto,
        )
      end

      it { is_expected.to eq(expected_result) }

      context "when decoding the serialized data is invalid" do
        let(:serialized_data) { Faker::Alphanumeric.alphanumeric }

        it "raises a DeserializationError" do
          expect { call }.to raise_error(described_class::DeserializationError)
        end
      end

      context "when the protobuf type is not registered" do
        before do
          allow(Google::Protobuf::DescriptorPool).to receive_message_chain(:generated_pool, :lookup).and_return(nil)
        end

        it "raises an UnknownEventTypeError" do
          expect { call }.to raise_error(described_class::UnknownEventTypeError)
        end
      end
    end
  end
end
