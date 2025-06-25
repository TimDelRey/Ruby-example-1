# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentMarathonPointsProducer do
  describe '.produce' do
    let(:student_id) { 123 }
    let(:points) { 50 }
    let(:topic_name) { 'test_topic' }
    let(:expected_payload) do
      {
        student_id: student_id,
        student_account_id: nil,
        marathon_points: points,
        type: 'loyalty_program',
        subject_id: nil
      }
    end

    subject(:produce_points) do
      described_class.new(student_id: student_id, points: points).call
    end

    before do
      allow(Kafka::EventProducer).to receive(:produce)
      stub_const('StudentMarathonPointsProducer::TOPIC', topic_name)
    end

    it 'sends message to Kafka' do
      produce_points

      expect(Kafka::EventProducer).to have_received(:produce).with(
        expected_payload,
        topic: topic_name,
        version: 4
      )
    end
  end
end
