namespace :csv do
  desc 'Process CSV file and send data to Kafka'
  task :process, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]
    unless file_path && File.exist?(file_path)
      puts "File not found: #{file_path}"
      next
    end

    parsed_file = CsvParser.new(file_path)
    batches = EggsCollectAndProduce.new(parsed_file)
    batches.create_and_send_batches
  end
end
