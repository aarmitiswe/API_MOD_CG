class Api::V1::OfferLettersController < ApplicationController
  before_action :set_job_application

  # {offer_letter: {name: "", grade: "", title:}}
  def generate
    # @e_signature = CompanyUser.where(company_id: @current_company.id, user_id: current_user.id).try(:last).try(:document_e_signature).try(:url)
    @e_signature = "NA"
    @jobseeker = @job_application.jobseeker
    @job = @job_application.job
    @salary_analysis = @job_application.salary_analyses.order(:created_at).first
    @offer_analysis = @job_application.offer_analyses.order(:created_at).first
    @all_organizations = @job.get_all_organizations
    render template: 'api/v1/offer_letters/generate_mod_offer_letter.html.erb', pdf: 'sample_offer_letter', handlers: [:erb], formats: [:html]

    # if Rails.application.secrets['OFFER_LETTERS']['medgulf']
    #   render template:'api/v1/offer_letters/generate_medgulf.html', pdf: 'sample_offer_letter', handlers: [:erb], formats: [:html]
    # elsif Rails.application.secrets['OFFER_LETTERS']['neom']
    #   render template:'api/v1/offer_letters/generate_neom.html', pdf: 'sample_offer_letter', handlers: [:erb], formats: [:html]
    # else
    #   render template: 'api/v1/offer_letters/generate.html', pdf: 'sample_offer_letter', handlers: [:erb], formats: [:html]
    # end
  end

  def generate_stc_contract
    # @e_signature = CompanyUser.where(company_id: @current_company.id, user_id: current_user.id).try(:last).try(:document_e_signature).try(:url)
    @e_signature = "NA"
    @jobseeker = @job_application.jobseeker
    @job = @job_application.job
    @salary_analysis = @job_application.salary_analyses.order(:created_at).first
    @offer_letter = @job_application.offer_letters.order(:created_at).first
    @all_organizations = @job.get_all_organizations
    render template: 'api/v1/offer_letters/generate_stc_contract.html.erb', pdf: 'sample_offer_letter', handlers: [:erb], formats: [:html]
  end

  def save_as_pdf (offer_letter_request, current_user)
    @offer_letter_request = offer_letter_request
    @jobseeker = @offer_letter_request.jobseeker
    @current_company = @offer_letter_request.job.company
    @current_user = current_user
    @job_request = @offer_letter_request.job.job_request

    pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/offer_letters/#{@offer_letter_request.offer_letter_type  || 'saudi_expat_external_offer'}.html.erb", layout: false)
    )
    pdf
  end
  
  private

    def set_job_application

      @job_application = JobApplication.find_by_id(params[:job_application_id])
      @jobseeker = @job_application.jobseeker
      @offer_letter_request = @job_application.job_application_status_changes.last.try(:offer_letter_request)
      @job_request = @job_application.job.job_request

    end

    def job_application_owner
      if @current_user.id == @job_application.jobseeker.user.id
        @current_ability.cannot params[:action].to_sym, OfferLetter
        authorize!(params[:action].to_sym, OfferLetter)
      end
    end
end
