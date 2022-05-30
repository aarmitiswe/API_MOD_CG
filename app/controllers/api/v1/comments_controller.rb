class Api::V1::CommentsController < ApplicationController
  before_action :set_blog
  before_action :set_comment, only: [:destroy, :change_status]
  before_action :comment_owner, only: [:destroy]

  # POST /comments
  # POST /comments.json
  def create
    @comment = @blog.comments.new(comment_params)

    if @currnet_user == @blog.author
      @comment.is_active = true
    else
      @comment.is_active = false
    end

    if @comment.save
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PUT /comments/:comment_id/change_status
  def change_status
    @comment.update_attribute(:is_active, params[:comment][:is_active])
    render json: @comment
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.update_attribute(:is_deleted, true)
    render nothing: true, status: 204
  end

  private
    def set_blog
      @blog = Blog.find_by_id(params[:blog_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find_by_id(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content).merge!({is_deleted: false, user_id: @current_user.id})
    end

    def comment_owner
      if params[:id].nil? || @comment.user_id != @current_user.id
        @current_ability.cannot params[:action].to_sym, Comment
        authorize!(params[:action].to_sym, Comment)
      end
    end
end
