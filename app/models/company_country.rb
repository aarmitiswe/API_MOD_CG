class CompanyCountry < ActiveRecord::Base
  belongs_to :country
  belongs_to :company
end
