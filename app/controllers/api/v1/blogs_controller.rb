class Api::V1::BlogsController < ApplicationController
  # Public view for index, show actions
  skip_before_action :authenticate_user, only: [:index, :show, :show_pdf, :tags]
  before_action :set_blog, only: [:update, :upload_avatar, :delete_avatar, :upload_video, :show_pdf, :update,
                                  :delete_video, :destroy, :like, :dislike]
  before_action :blog_owner, only: [:update, :destroy, :upload_avatar, :delete_avatar, :upload_video, :delete_video]

  # This is called if send wrong params to get blogs in order
  #rescue_from NoMethodError, with: :render_exception_error

  # GET /blogs
  # GET /blogs?order=comments|views
  # GET /blogs?q[tags_id_in][]=32
  def index
    params[:order] ||= "date"
    @q = Blog.active.send("order_by_#{params[:order]}").ransack(params[:q])
    per_page = params[:per_page] || Blog.per_page
    @blogs = @q.result.includes(:tags).paginate(page: params[:page], per_page: per_page)
    render json: @blogs, meta: pagination_meta(@blogs), each_serializer: BlogListSerializer, root: :blogs
  end

  # GET /blogs/tags
  def tags
    @tags = Tag.where(id: BlogTag.where(blog_id: Blog.active.pluck(:id)).pluck(:tag_id))
    render json: @tags, each_serializer: TagSerializer, root: :tags
  end

  # GET /blogs/1
  # GET /blogs/1.json
  def show
    @blog = Blog.active.find_by_id(params[:id])
    if @blog
      @blog.increase_viewers
      render json: @blog
    else
      render json: {errors: {blog: "Not Found"}}, status: :not_found
    end
  end

  def show_pdf
    @blog.increase_downloader
    # render template: "api/v1/blogs/show_pdf", handlers: [:erb], formats: [:html]
    render pdf: 'blog', handlers: [:erb], formats: [:html]
  end

  # POST /blogs
  # POST /blogs.json
  def create
    @blog = Blog.new(blog_params)
    if @blog.save && @blog.add_tags(params[:blog][:tags])
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /blogs/1
  # PATCH/PUT /blogs/1.json
  def update
      if @blog.update(blog_params) && @blog.add_tags(params[:blog][:tags])
        render json: @blog
      else
        render json: @blog.errors, status: :unprocessable_entity
      end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.json
  # TODO: This soft destroy ... I need to be sure that's good or not ?
  def destroy
    # @blog.update_attribute(:is_deleted, true)
    @blog.destroy
    render nothing: true, status: 204
  end

  def upload_avatar
    if @blog.upload_avatar(params[:blog][:avatar])
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  def delete_avatar
    @blog.avatar = nil
    if @blog.save
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  def upload_video
    if @blog.upload_video(params[:blog][:video])
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  def delete_video
    @blog.video = nil
    if @blog.save
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  def like
    @like = Like.find_or_create_by(blog_id: @blog.id, user_id: @current_user.id)
    render json: @blog, serializer: LikeBlogSerializer, root: :blog
  end

  def dislike
    @like = Like.find_by(blog_id: @blog.id, user_id: @current_user.id)
    @like.destroy unless @like.nil?
    render json: @blog, serializer: LikeBlogSerializer, root: :blog
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_params
      params.require(:blog).permit(:title, :description, :is_deleted, :avatar, :video, :video_link, :views_count, :downloads_count, :company_user_id)
    end

    def render_exception_error
      render json: {message: "Wrong Params"}, status: :bad_request
    end

    def blog_owner
      if params[:id].nil? || !@current_company.blogs.pluck(:id).include?(params[:id].to_i)
        @current_ability.cannot params[:action].to_sym, Blog
        authorize!(params[:action].to_sym, Blog)
      end
    end
end
