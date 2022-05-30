class AddSalaryAndOfferReferencesToOfferRequisition < ActiveRecord::Migration
  def change
    add_reference :offer_requisitions, :salary_analysis, index: true, foreign_key: :salary_analysis_id
    add_reference :offer_requisitions, :offer_analysis, index: true, foreign_key: :offer_analysis_id
  end
end
