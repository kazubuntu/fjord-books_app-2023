# frozen_string_literal: true

class Reports::CommentsController < ApplicationController
  before_action :ensure_correct_user, only: :destroy

  # POST /reports/1/comments
  def create
    @report = Report.find(params[:report_id])
    @comment = @report.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
    redirect_to report_url(@report)
  end

  # DELETE /reports/1/comments/1
  def destroy
    report = Report.find(params[:report_id])
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to report_url(report)
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def ensure_correct_user
    @comment = Comment.find(params[:id])
    return if @comment.user == current_user

    redirect_to root_url
  end
end
