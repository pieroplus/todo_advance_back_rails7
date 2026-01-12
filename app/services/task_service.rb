class TaskService
  include ServiceResult

  def initialize(params = {})
    @params = params
  end

  def create_task
    task = Task.new(normalized_params)

    if task.save
      Result.success(task)
    else
      Result.failure(task.errors)
    end
  end

  def duplicate_task(task)
    duplicated_task = task.duplicate

    if duplicated_task.save
      Result.success(duplicated_task)
    else
      Result.failure(duplicated_task.errors)
    end
  end

  private

  def normalized_params
    {
      name: @params[:name],
      explanation: @params[:explanation],
      status: @params[:status],
      priority: @params[:priority],
      genre_id: @params[:genreId],
      deadline_date: @params[:deadlineDate]
    }.compact
  end
end
