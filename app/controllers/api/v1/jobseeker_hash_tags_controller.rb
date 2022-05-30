class Api::V1::JobseekerHashTagsController < ApplicationController
  before_action :set_jobseeker_hash_tag, only: [:show, :edit, :update, :destroy]

  # GET /jobseeker_hash_tags
  # GET /jobseeker_hash_tags.json
  def index
    @jobseeker_hash_tags = JobseekerHashTag.all
  end

  # GET /jobseeker_hash_tags/1
  # GET /jobseeker_hash_tags/1.json
  def show
  end

  # POST /jobseeker_hash_tags
  # POST /jobseeker_hash_tags.json
  def create
    @jobseeker_hash_tag = JobseekerHashTag.new(jobseeker_hash_tag_params)

    if @jobseeker_hash_tag.save
      render json: @jobseeker_hash_tag
    else
      render json: @jobseeker_hash_tag.errors, status: :unprocessable_entity
    end
  end

  # def create_bulk
  #   @jobseeker = Jobseeker.find_by_id(params[:jobseeker_hash_tag][:jobseeker_id])
  #
  #   if @jobseeker.update(hash_tag_params)
  #     render json: @jobseeker
  #   else
  #     render json: @jobseeker.errors, status: :unprocessable_entity
  #   end
  # end

  def create_bulk_by_nested_attributes
    # new_jobseeker_hash_tags = params[:hash_tags_attributes].map{|hash_tag| JobseekerHashTag.new({jobseeker_id: params[:jobseeker_id], hash_tag_attributes: hash_tag})}
    new_jobseeker_hash_tags = params[:hash_tags_attributes].map{|hash_tag| JobseekerHashTag.new(jobseeker_hash_tag_hash(ActionController::Parameters.new({jobseeker_id: params[:jobseeker_id], hash_tag_attributes: hash_tag})))}

    response_arr = new_jobseeker_hash_tags.map { |jobseeker_hash_tag|  jobseeker_hash_tag.save ?  jobseeker_hash_tag : jobseeker_hash_tag.errors }

    render json: {result: response_arr}
  end

  def create_bulk
    @jobseeker = Jobseeker.find_by_id(params[:jobseeker_id])
    if @jobseeker
      JobseekerHashTag.create_bulk params[:jobseeker_id], params[:hash_tags_attributes]
      render json: @jobseeker.hash_tags, each_serializer: HashTagSerializer, root: :hash_tags
    else
      render json: {error: "Wrong Jobseeker ID"}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_hash_tags/1
  # PATCH/PUT /jobseeker_hash_tags/1.json
  def update
    respond_to do |format|
      if @jobseeker_hash_tag.update(jobseeker_hash_tag_params)
        format.html { redirect_to @jobseeker_hash_tag, notice: 'Jobseeker hash tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @jobseeker_hash_tag }
      else
        format.html { render :edit }
        format.json { render json: @jobseeker_hash_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobseeker_hash_tags/1
  # DELETE /jobseeker_hash_tags/1.json
  def destroy
    @jobseeker_hash_tag.destroy
    respond_to do |format|
      format.html { redirect_to jobseeker_hash_tags_url, notice: 'Jobseeker hash tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_hash_tag
      @jobseeker_hash_tag = JobseekerHashTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_hash_tag_params
      params.require(:jobseeker_hash_tag).permit(:jobseeker_id, hash_tag_attributes: [:id, :name, :_destroy])
    end

    def jobseeker_hash_tag_hash hash
      hash.permit(:jobseeker_id, hash_tag_attributes: [:id, :name, :_destroy])
    end

    # def update_params
    #   params[:hash_tags_attributes].each {|obj| obj[:jobseeker_id] = params[:jobseeker_id]}
    # end
end
