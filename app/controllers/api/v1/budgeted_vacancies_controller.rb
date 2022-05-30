class Api::V1::BudgetedVacanciesController < ApplicationController
  before_action :set_budgeted_vacancy, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key



  # GET /api/v1/departments
  # GET /api/v1/departments?order=jobs
  def index
    per_page = params[:all] ? BudgetedVacancy.count : BudgetedVacancy.per_page
    params[:q] ||= {}

    @q = BudgetedVacancy.order('id  desc').ransack(params[:q])

    @budgeted_vacancy = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @budgeted_vacancy, each_serializer: BudgetedVacancySerializer, ar: params[:ar], meta: pagination_meta(@budgeted_vacancy)
  end

  # Get count of used budgeted vacancies
  def count_used_budgeted_vacancies
    @budgeted_vacancies_count =JobRequest.count_used_budgeted_vacancies(@budgeted_vacancy.id)

    if params[:job_request_id]
      @own_budgeted_vacancies_count = JobRequest.find_by_id(params[:job_request_id]).total_number_vacancies
      @budgeted_vacancies_count =  @budgeted_vacancies_count - @own_budgeted_vacancies_count
    end

    render json: @budgeted_vacancies_count
  end

  # GET /api/v1/departments/1
  def show
    render json: @budgeted_vacancy
  end

  # POST /departments
  # POST /departments.json
  def create
    @budgeted_vacancy = BudgetedVacancy.create(budgeted_vacancy_params)

    if @budgeted_vacancy
      render json: @budgeted_vacancy
    else
      render json: @budgeted_vacancy.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    if @budgeted_vacancy.update(budgeted_vacancy_params)
      render json: @budgeted_vacancy
    else
      render json: @budgeted_vacancy.errors, status: :unprocessable_entity
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    if @budgeted_vacancy.destroy
    render nothing: true, status: :no_content
   else
    render json: @budgeted_vacancy.error
   end
  end

  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_budgeted_vacancy
      @budgeted_vacancy = BudgetedVacancy.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def budgeted_vacancy_params
      params.require(:budgeted_vacancy).permit(:job_title, :position_id, :grade_id, :job_experience_level_id,
                                               :job_type_id, :no_vacancies, :section_id, :unit_id, :department_id, :new_section_id)

    end


end
