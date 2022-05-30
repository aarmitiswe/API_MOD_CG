class Api::V1::CandidateInformationDocumentsController < ApplicationController
  before_action :set_candidate_information_document, only: [:update_status, :save_as_pdf]

  def update_status
    if @candidate_information_document.update(candidate_information_document_params)
      render json: @candidate_information_document
    else
      render json: @candidate_information_document.errors, status: :unprocessable_entity
    end
  end

  def save_as_pdf
    # Security Clearance pdf
    # render  :pdf => "file.pdf", :template => 'api/v1/security_clearance/security_clearance.html.erb'
    render pdf: 'security_clearance', handlers: [:erb], formats: [:html]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_information_document
    @candidate_information_document = CandidateInformationDocument.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def candidate_information_document_params
    params.require(:candidate_information_document).permit(:status, :document_report).merge!({user_id: @current_user.id})

  end

end
