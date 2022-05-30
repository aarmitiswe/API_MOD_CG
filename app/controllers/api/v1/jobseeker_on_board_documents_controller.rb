class Api::V1::JobseekerOnBoardDocumentsController < ApplicationController
  before_action :set_jobseeker_on_board_document, only: [:show, :edit, :update, :destroy]

  # GET /jobseeker_on_board_documents
  # GET /jobseeker_on_board_documents.json
  def index
    @jobseeker_on_board_documents = JobseekerOnBoardDocument.all
    render json: @jobseeker_on_board_documents
  end

  # GET /jobseeker_on_board_documents/1
  # GET /jobseeker_on_board_documents/1.json
  def show
  end

  # GET /jobseeker_on_board_documents/new
  def new
    @jobseeker_on_board_document = JobseekerOnBoardDocument.new
  end

  # GET /jobseeker_on_board_documents/1/edit
  def edit
  end

  # POST /jobseeker_on_board_documents
  # POST /jobseeker_on_board_documents.json
  def create
    @jobseeker_on_board_document = JobseekerOnBoardDocument.new(jobseeker_on_board_document_params)
    if @jobseeker_on_board_document.save
      render json: @jobseeker_on_board_document
    else
      render json: @jobseeker_on_board_document.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_on_board_documents/1
  # PATCH/PUT /jobseeker_on_board_documents/1.json
  def update
    if @jobseeker_on_board_document.update(jobseeker_on_board_document_params)
      render json: @jobseeker_on_board_document
    else
      render json: @jobseeker_on_board_document.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_on_board_documents/1
  # DELETE /jobseeker_on_board_documents/1.json
  def destroy
    @jobseeker_on_board_document.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_on_board_document
      @jobseeker_on_board_document = JobseekerOnBoardDocument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_on_board_document_params
      params[:jobseeker_on_board_document] ||= {}
      params[:jobseeker_on_board_document][:document] ||= params[:document]
      params[:jobseeker_on_board_document][:jobseeker_id] ||= params[:jobseeker_id]
      params[:jobseeker_on_board_document][:type_of_document] ||= params[:type_of_document]
      params.require(:jobseeker_on_board_document).permit(:jobseeker_id, :document, :type_of_document)
    end
end
