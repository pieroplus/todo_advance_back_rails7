class Task < ApplicationRecord
  belongs_to :genre

  enum priority: { low: 0, medium: 1, high: 2 }
  enum status: { not_started: 0, in_progress: 1, completed: 2 }

  # 複製時の初期ステータス
  INITIAL_STATUS = 0

  def duplicate
    dup.tap do |task|
      task.name = "#{name}(コピー)"
      task.status = INITIAL_STATUS
      task.deadline_date = nil
    end
  end
end
