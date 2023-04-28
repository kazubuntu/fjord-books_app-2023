# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)

    if @report.save
      mentioned_ids = find_mentioned_ids(@report.content)
      create_mentioning_reports(mentioned_ids)
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
      old_mentioned_ids = @report.mentioning_report_ids
      new_mentioned_ids = find_mentioned_ids(@report.content)
      destroy_mentioning_reports(old_mentioned_ids - new_mentioned_ids)
      create_mentioning_reports(new_mentioned_ids - old_mentioned_ids)
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  def find_mentioned_ids(content)
    content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.map(&:to_i).uniq
  end

  def create_mentioning_reports(mentioned_ids)
    mentioned_ids.each { |mentioned_id| @report.active_relationships.build(mentioned_id:).save unless mentioned_id == @report.id }
  end

  def destroy_mentioning_reports(mentioned_ids)
    mentioned_ids.each { |mentioned_id| @report.active_relationships.find_by(mentioned_id:).destroy }
  end
end
