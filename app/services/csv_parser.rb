# frozen_string_literal: true

require 'csv'

class CsvParser
  include Enumerable

  def initialize(file_path)
    @file_path = file_path
  end

  def each
    CSV.foreach(@file_path, headers: true) do |row|
      yield({ student_id: row['student_id'].to_i, amount_eggs: row['amount_eggs'].to_i })
    end
  end
end
