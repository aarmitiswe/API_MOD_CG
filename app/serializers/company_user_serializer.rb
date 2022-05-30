# This serializer for users related to company
class CompanyUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :role_id, :position, :email, :avatar, :active, :join_date, :employer_id,
             :section, :new_section, :department, :office, :unit, :grade, :is_recruiter, :is_interviewer, :ext_employer_id,
             :start_date, :end_date, :document_e_signature, :employer_id, :document_e_signature_url, :permissions, :is_approver,
             :oracle_id

  has_one :role
  has_many :organizations

  def join_date
    object.created_at
  end

  def document_e_signature_url
  	CompanyUser.find_by(user_id: object.id, company_id: object.company.id).document_e_signature.try(:url)
  end

  def employer_id
    CompanyUser.find_by(user_id: object.id, company_id: object.company.id).try(:id)
  end

  def permissions
    object.permissions_names
  end
end
