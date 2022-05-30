class Api::V1::JobseekerRequiredDocumentsController < ApplicationController
  before_action :set_jobseeker_required_document, only: [:show, :update, :destroy]

  # GET /jobseeker_required_documents
  # GET /jobseeker_required_documents.json
  def index
    params[:q] ||= {}
    @q = JobseekerRequiredDocument.ransack(params[:q])
    @jobseeker_required_documents = @q.result
    render json: @jobseeker_required_documents
  end

  # GET /jobseeker_required_documents/1
  # GET /jobseeker_required_documents/1.json
  def show
    render json: @jobseeker_required_document
  end

  # POST /jobseeker_required_documents
  # POST /jobseeker_required_documents.json
  def create
    @jobseeker_required_document = JobseekerRequiredDocument.new(jobseeker_required_document_params)

    if @jobseeker_required_document.save
      render json: @jobseeker_required_document
    else
      render json: @jobseeker_required_document.errors, status: :unprocessable_entity
    end
  end

  # POST /jobseeker_required_documents/create_bulk
  # POST /jobseeker_required_documents/create_bulk.json
  def create_bulk
    @jobseeker_required_documents = []
    # params[:jobseeker_required_documents].each do |jobseeker_required_document_obj|
    #   jobseeker_required_document_params[:documents].each do |document|
    #     jobseeker_required_document = JobseekerRequiredDocument.new({
    #                                                                     document_type: jobseeker_required_document_obj[:document_type],
    #                                                                     document: document,
    #                                                                     job_application_status_change_id: jobseeker_required_document_obj[:job_application_status_change_id],
    #                                                                     status: JobseekerRequiredDocument::UPLOADED_STATUS
    #                                                                 })
    #     jobseeker_required_document.save
    #     @jobseeker_required_documents << jobseeker_required_document
    #   end
    # end

    params[:jobseeker_required_documents].each do |jobseeker_required_document_obj|
        jobseeker_required_document = JobseekerRequiredDocument.new({
                                                                        document_type: jobseeker_required_document_obj[:document_type],
                                                                        document: jobseeker_required_document_obj[:document],
                                                                        employer_comment: jobseeker_required_document_obj[:employer_comment],
                                                                        job_application_status_change_id: jobseeker_required_document_obj[:job_application_status_change_id],
                                                                        status: JobseekerRequiredDocument::UPLOADED_STATUS
                                                                    })
        jobseeker_required_document.save
        @jobseeker_required_documents << jobseeker_required_document
    end

    render json: @jobseeker_required_documents
  end

  # POST /jobseeker_required_documents/update_bulk
  # POST /jobseeker_required_documents/update_bulk.json
  def update_bulk
    @jobseeker_required_documents = []
    params[:jobseeker_required_documents].each do |jobseeker_required_document_obj|
      if jobseeker_required_document_obj[:id]

        jobseeker_required_document = JobseekerRequiredDocument.find_by_id(jobseeker_required_document_obj[:id])

        if jobseeker_required_document

          # jobseeker_required_document.update(jobseeker_required_document_obj.permit(:document_type, :document, :employer_comment, :job_application_status_change_id, :status, :_destroy))
          if jobseeker_required_document_obj[:_destroy]
            jobseeker_required_document.destroy
          else
            jobseeker_required_document.update({
                                                   document_type: jobseeker_required_document_obj[:document_type],
                                                   document: jobseeker_required_document_obj[:document],
                                                   employer_comment: jobseeker_required_document_obj[:employer_comment],
                                                   job_application_status_change_id: jobseeker_required_document_obj[:job_application_status_change_id],
                                                   status: jobseeker_required_document_obj[:status]
                                               })
          end
        end
      else
        jobseeker_required_document_obj[:status] = JobseekerRequiredDocument::UPLOADED_STATUS
        jobseeker_required_document = JobseekerRequiredDocument.new(jobseeker_required_document_obj.permit(:document_type, :document, :employer_comment, :job_application_status_change_id, :status))
        # jobseeker_required_document = JobseekerRequiredDocument.new({
        #                                                                 document_type: jobseeker_required_document_obj[:document_type],
        #                                                                 document: jobseeker_required_document_obj[:document],
        #                                                                 employer_comment: jobseeker_required_document_obj[:employer_comment],
        #                                                                 job_application_status_change_id: jobseeker_required_document_obj[:job_application_status_change_id],
        #                                                                 status: JobseekerRequiredDocument::UPLOADED_STATUS
        #                                                             })
        jobseeker_required_document.save
      end

      @jobseeker_required_documents << jobseeker_required_document
    end

    render json: @jobseeker_required_documents
  end

  # PATCH/PUT /jobseeker_required_documents/1
  # PATCH/PUT /jobseeker_required_documents/1.json
  def update
    if @jobseeker_required_document.update(jobseeker_required_document_params)
      render json: @jobseeker_required_document
    else
      render json: @jobseeker_required_document.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_required_documents/1
  # DELETE /jobseeker_required_documents/1.json
  def destroy
    @jobseeker_required_document.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_required_document
      @jobseeker_required_document = JobseekerRequiredDocument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_required_document_params
      params.require(:jobseeker_required_document).permit(:document_type, :document, :job_application_status_change_id, :status)
    end
end
