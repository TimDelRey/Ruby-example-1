# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EggsCollectAndProduce do
  describe '#create_and_send_batches' do
    let!(:csv_parser) { CsvParser.new('spec/fixtures/valid_data.csv') }
    subject { described_class.new(csv_parser) }

    before do
      allow(StudentMarathonPointsProducer).to receive(:new).and_return(double(call: true))
      stub_const('EggsCollectAndProduce::BATCH_SIZE', 2)
    end

    context 'when valid CSV file' do
      it 'creates batches and sends messages to Kafka' do
        start_time = Time.current

        subject.create_and_send_batches

        expect(StudentMarathonPointsProducer).to have_received(:new).with(student_id: 1, points: 3)
        expect(StudentMarathonPointsProducer).to have_received(:new).with(student_id: 2, points: 4)
        expect(StudentMarathonPointsProducer).to have_received(:new).with(student_id: 11, points: 33)

        end_time = Time.current
        expect(end_time - start_time).to be >= EggsCollectAndProduce::SLEEP_TIME
      end
    end

    context 'when some messages dont send' do
      it 'creates and saves failed messages to csv file when sending to Kafka fails' do
        allow(StudentMarathonPointsProducer).to receive(:new).and_wrap_original do |original, **args|
          producer = original.call(**args)
          allow(producer).to receive(:call).and_wrap_original do |method|
            student_id = producer.student_id
            points = producer.points

            raise StandardError, 'Kafka error' if [[1, 3], [11, 33]].include?([student_id, points])

            method.call
          end
          producer
        end

        subject.create_and_send_batches

        failed_messages = CSV.read(EggsCollectAndProduce::FAILED_MESSAGES_FILE, headers: true).map do |row|
          [row['student_id'], row['amount_eggs']]
        end

        expect(failed_messages).to contain_exactly(
          ['1', '3'],
          ['11', '33']
        )
      end

      after do
        if File.exist?(EggsCollectAndProduce::FAILED_MESSAGES_FILE)
          File.delete(EggsCollectAndProduce::FAILED_MESSAGES_FILE)
        end
      end
    end
  end
end
