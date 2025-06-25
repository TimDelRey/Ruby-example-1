# frozen_string_literal: true

class EggsCollectAndProduce
  BATCH_SIZE = 1000
  SLEEP_TIME = 1
  FAILED_MESSAGES_FILE = 'log/failed_messages.csv'

  def initialize(parser)
    @parser = parser
  end

  def create_and_send_batches
    @parser.each_slice(BATCH_SIZE) do |batch|
      send_to_kafka(batch)
      sleep SLEEP_TIME
    end
  end

  private

  def send_to_kafka(batch)
    failed_messages = []
    batch.each do |message|
      StudentMarathonPointsProducer.new(student_id: message[:student_id], points: message[:amount_eggs]).call
    rescue => e
      puts "Failed to send message: #{message}, error: #{e.message}"
      failed_messages << message
    end
    save_failed_messages(failed_messages) unless failed_messages.empty?
  end

  def save_failed_messages(messages)
    ensure_failed_messages_file
    CSV.open(FAILED_MESSAGES_FILE, 'a') do |csv|
      messages.each do |message|
        csv << [message[:student_id], message[:amount_eggs]]
      end
    end
    puts "Saved #{messages.size} failed messages to #{FAILED_MESSAGES_FILE}"
  end

  def ensure_failed_messages_file
    return if File.exist?(FAILED_MESSAGES_FILE)

    CSV.open(FAILED_MESSAGES_FILE, 'w') do |csv|
      csv << %w[student_id amount_eggs]
    end
  end
end
