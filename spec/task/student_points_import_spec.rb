# spec/lib/tasks/student_points_import_spec.rb
require 'rails_helper'
require 'rake'

RSpec.describe 'csv:process', type: :task do
  before do
    Rake.application.rake_require('tasks/student_points_import')
    Rake::Task.define_task(:environment)
    Rake::Task['csv:process'].reenable
  end

  let(:valid_file_path) { 'spec/fixtures/valid_data.csv' }
  let(:invalid_file_path) { 'spec/fixtures/invalid_data.csv' }

  it 'import a valid CSV file' do
    allow(CsvParser).to receive(:new).with(valid_file_path).and_return(double('CsvParser', each: []))
    allow(EggsCollectAndProduce).to receive(:new).and_return(double('EggsCollectAndProduce', create_and_send_batches: true))

    Rake::Task['csv:process'].invoke(valid_file_path)

    expect(CsvParser).to have_received(:new).with(valid_file_path)
    expect(EggsCollectAndProduce).to have_received(:new)
  end

  it 'shows error if the file is not found' do
    expect do
      Rake::Task['csv:process'].invoke(invalid_file_path)
    end.to output("File not found: #{invalid_file_path}\n").to_stdout
  end
end
