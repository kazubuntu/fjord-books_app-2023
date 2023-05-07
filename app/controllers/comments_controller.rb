# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :ensure_correct_user, only: :destroy
  # POST /books/1/comments
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to @commentable
    else
      @comments = @commentable.comments
      render_commentable
    end
  end

  # DELETE /books/1/comments/1
  def destroy
    @comment.destroy
    redirect_to @commentable
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
