class CompanySerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :name,
             :ar_name,
             :is_premium,
             :summary,
             :establishment_date,
             :website,
             :profile_image,
             :hero_image,
             :address_line1,
             :address_line2,
             :phone,
             :fax,
             :contact_email,
             :contact_person,
             :po_box,
             :google_plus_page_url,
             :linkedin_page_url,
             :facebook_page_url,
             :twitter_page_url,
             :followers_count,
             :opened_jobs_count, 
             :is_follow_by_current_user,
             :avatar,
             :cover,
             :cover_content_type,
             :video_cover_screenshot,
             :video_our_management,
             :video_our_management_screenshot,
             :owner_name,
             :owner_designation,
             :latitude,
             :longitude,
             :total_male_employees,
             :total_female_employees


  has_one :sector
  has_one :current_city
  has_one :current_country
  has_one :company_size, root: :size
  has_one :company_type, root: :type
  has_one :company_classification, root: :classification
  has_many :company_countries, root: :company_geographical_presence, serializer: CompanyCountrySerializer

  def is_follow_by_current_user
    object.is_follow_by_user(current_user)
  end
end
