class TasksController < ApplicationController
  before_action :select_task, only: [:update, :destroy, :update_status, :duplicate]
  skip_before_action :verify_authenticity_token

  def index
    tasks_all
  end

  def create
    result = TaskService.new(params).create_task

    if result.success?
      @tasks = Task.all
      render :all_tasks
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    @task.update(task_params)
    tasks_all
  end

  def destroy
    @task.destroy
    tasks_all
  end

  def update_status
    @task.update(status: params[:status])
    tasks_all
  end

  def duplicate
    result = TaskService.new.duplicate_task(@task)

    if result.success?
      @task = result.value
      render :duplicate, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def report
    @report = TaskReportService.generate_report
    render :report
  end

  private

  def task_params
    params.permit(:name, :explanation, :status, :priority).merge(genre_id: params[:genreId], deadline_date: params[:deadlineDate])
  end

  def select_task
    @task = Task.find(params[:id])
  end

  def tasks_all
    @tasks = Task.all
    render :all_tasks
  end
end
