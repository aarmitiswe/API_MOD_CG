class Api::V1::NotesController < ApplicationController
  before_action :set_job_application
  before_action :job_application_owner

  # GET /notes
  # GET /notes.json
  def index
    @notes = @job_application.notes.order(created_at: :desc)
    render json: @notes
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = @job_application.notes.new(note_strong_params)

    if @note.save
      render json: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private
    def set_job_application
      @job_application = @current_company.job_applications.find_by_id(params[:job_application_id])
      # If Nil .. so, employer try to get or edit job_application on another company
      unauthorized_user if @job_application.nil?
    end

    def note_strong_params
      @company_user = CompanyUser.find_by(user_id: @current_user.id, company_id: @current_company.id)
      params.require(:note).permit(:note).merge!({job_application_id: params[:job_application_id],
                                                  company_user_id: @company_user.id})
    end

    # TODO: Debug it later .. it's weird issue .. If create Note .. It's go inside this method before ability method
    # I need to search about this issue
    def note_params
    end

    def unauthorized_user
      authorize!(params[:action].to_sym, JobApplication, id: params[:job_application_id])
    end

    def job_application_owner
      if params[:job_application_id].nil? || !@current_company.job_applications.pluck(:id).include?(params[:job_application_id].to_i)

        @current_ability.cannot params[:action].to_sym, Note
        authorize!(params[:action].to_sym, Note)
      end
    end
end
