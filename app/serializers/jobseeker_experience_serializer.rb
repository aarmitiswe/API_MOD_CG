class JobseekerExperienceSerializer < ActiveModel::Serializer
  include HtmlWithArrayHelper
  include DateHelper
  # Object {id: 1, company: {id: null, name: "AAA"}, start_dat: "", end_date: "", sector: {id: 2, name: ""}, city: {id: 3, name: "AA"},
  # country: {id: 2, name: ""}, document: "http://", document_file_name: "aa.doc", roles: ["AAA", "BBB", "CCC"]}
  attributes :id, :company, :department,
             :position, :from, :to, :document_file_name, :document,
             :description, :duration


  has_one :city
  has_one :country
  has_one :sector


  def company
    object.company ? {id: object.company.id, name: object.company.name} : {id: nil, name: object.company_name}
  end

  def description
    return [] unless object.description
    convert_html_list_to_array object.description
  end

  def country
    object.country || object.city.try(:country)
  end

  def duration
    subtract_to_years_months(object.from, object.to)
  end
end
