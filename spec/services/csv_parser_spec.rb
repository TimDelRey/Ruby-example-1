# spec/lib/csv_parser_spec.rb

require 'rails_helper'

RSpec.describe CsvParser do
  describe '#each' do
    subject { CsvParser.new(file_path).to_a }

    context 'when CSV file has valid data' do
      let(:file_path) { 'spec/fixtures/valid_data.csv' }

      it 'parses valid CSV' do
        expect(subject).to eq([
          { student_id: 1, amount_eggs: 3 },
          { student_id: 2, amount_eggs: 4 },
          { student_id: 11, amount_eggs: 33 }
        ])
      end
    end

    context 'when CSV file is empty' do
      let(:file_path) { 'spec/fixtures/empty.csv' }

      it 'non parsing empty file' do
        expect(subject).to be_empty
      end
    end

    context 'when CSV file has non-numbers' do
      let(:file_path) { 'spec/fixtures/non_numeric.csv' }

      it 'converts non-numbers into zero' do
        expect(subject).to eq([
          { student_id: 0, amount_eggs: 0 },
          { student_id: 0, amount_eggs: 0 }
        ])
      end
    end
  end
end
