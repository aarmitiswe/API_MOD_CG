class OfferLetterSerializer < ActiveModel::Serializer
  attributes :id, :document, :joining_date, :shared_to_stc_at, :sent_to_candidate_at, :received_from_stc_at, :jobseeker_status,
             :candidate_dob,
             :candidate_second_name, :candidate_third_name, :candidate_birth_city, :candidate_birth_country, :candidate_nationality,
             :candidate_religion, :candidate_gender
end
