class SimilarCareersSerializer < ActiveModel::Serializer
  has_many :similar_jobs, serializer: JobListSerializer
  has_many :similar_companies, serializer: CompanyListSerializer
end