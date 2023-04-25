# frozen_string_literal: true

class Reports::CommentsController < ApplicationController
  # POST /reports/1/comments
  def create
    @report = Report.find(params[:report_id])
    @comment = @report.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
    redirect_to report_url(@report)
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
