class BankAccountSerializer < ActiveModel::Serializer
  attributes :id, :account_number, :iban_number, :bank_name
  has_one :jobseeker
end
