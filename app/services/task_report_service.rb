class TaskReportService
  def self.generate_report
    new.generate_report
  end

  def generate_report
    status_counts = Task.group(:status).count
    total_count = Task.count

    {
      total_count: total_count,
      count_by_status: build_count_by_status(status_counts),
      completion_rate: calculate_completion_rate(status_counts['completed'] || 0, total_count)
    }
  end

  private

  def build_count_by_status(status_counts)
    {
      not_started: status_counts['not_started'] || 0,
      in_progress: status_counts['in_progress'] || 0,
      completed: status_counts['completed'] || 0
    }
  end

  def calculate_completion_rate(completed_count, total_count)
    return 0.0 if total_count.zero?

    (completed_count.to_f / total_count * 100).round(1)
  end
end
