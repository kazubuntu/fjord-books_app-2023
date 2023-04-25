# frozen_string_literal: true

class Books::CommentsController < ApplicationController
  # POST /books/1/comments
  def create
    @book = Book.find(params[:book_id])
    @comment = @book.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
    redirect_to book_url(@book)
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
