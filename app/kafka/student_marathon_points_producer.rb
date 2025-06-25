# frozen_string_literal: true

class StudentMarathonPointsProducer
  TOPIC = 'uchiru.student_marathon_points'
  VERSION = 4

  attr_reader :student_id, :points

  def initialize(student_id:, points:)
    @student_id = student_id
    @points = points
  end

  def call
    payload = {
      student_id: @student_id,
      student_account_id: nil,
      marathon_points: @points,
      type: 'loyalty_program',
      subject_id: nil
    }

    Kafka::EventProducer.produce(
      payload,
      topic: TOPIC,
      version: VERSION
    )
  end
end
