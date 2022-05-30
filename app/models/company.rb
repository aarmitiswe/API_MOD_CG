class Company < ActiveRecord::Base
  include Pagination
  include SearchParams
  include VideoUpload
  belongs_to :sector
  belongs_to :company_size
  belongs_to :company_type
  belongs_to :company_classification
  # this for address
  belongs_to :current_country, class_name: Country, foreign_key: 'current_country_id'
  belongs_to :current_city, class_name: City, foreign_key: 'current_city_id'
  has_many :company_countries, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :job_applications, through: :jobs, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :blogs, through: :company_users, dependent: :destroy
  has_many :countries, through: :company_countries
  has_many :users, through: :company_users, dependent: :destroy
  has_many :company_followers, dependent: :destroy
  has_many :followers, through: :company_followers, source: :jobseeker
  has_many :jobseeker_experiences, dependent: :nullify
  has_many :benefits, through: :jobs

  # Culture
  has_many :cultures, dependent: :destroy
  # Company Member
  has_many :company_members, dependent: :destroy
  # Subscriptions
  has_many :company_subscriptions, dependent: :destroy
  has_many :packages, through: :company_subscriptions


  # No Need medium: "100x100>", thumb: "70x70>"
  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]

  # No Need medium: "70x90>", thumb: "35x40>"
  has_attached_file :cover, dependent: :destroy

  validates_attachment_content_type :cover, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
                                                           "video/x-msvideo", "video/avi", "video/quicktime",
                                                           "video/3gpp", "video/x-ms-wmv", "video/mp4",
                                                           "flv-application/octet-stream", "video/x-flv",
                                                           "video/mpeg", "video/mpeg4", "video/x-la-asf",
                                                           "video/x-ms-asf", "flv-application/octet-stream",
                                                           "video/flv", "video/webm"]




  has_attached_file :video_cover_screenshot, dependent: :destroy

  validates_attachment_content_type :video_cover_screenshot, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]



  has_attached_file :video_our_management, dependent: :destroy

  validates_attachment_content_type :video_our_management, content_type: ["video/x-msvideo", "video/avi", "video/quicktime",
                                                           "video/3gpp", "video/x-ms-wmv", "video/mp4",
                                                           "flv-application/octet-stream", "video/x-flv",
                                                           "video/mpeg", "video/mpeg4", "video/x-la-asf",
                                                           "video/x-ms-asf", "flv-application/octet-stream",
                                                           "video/flv", "video/webm"]


  has_attached_file :video_our_management_screenshot, dependent: :destroy

  validates_attachment_content_type :video_our_management_screenshot, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]


  scope :order_by_alphabetical, -> {  order("name ASC") }
  # Left join to get companies that hasn't followers
  scope :order_by_followers, -> {  joins("LEFT JOIN company_followers ON company_followers.company_id = companies.id")
                                       .group("companies.id")
                                       .order("count(company_followers.id) DESC") }

  scope :order_by_jobs, -> {  joins("LEFT JOIN jobs ON jobs.company_id = companies.id")
                                       .group("companies.id")
                                       .order("count(jobs.id) DESC") }

  scope :active, -> { where(active: true) }

  def company_subscription
    self.company_subscriptions.last
  end

  def self.add_ar_name
    Company.first.update(ar_name:"وزارة الدفاع - المملكة العربية السعودية")
  end

  def owner
    self.users.find_by(role_id: Role.find_by_name(Role::SUPER_ADMIN).try(:id))
  end

  def admins
    self.users.where(role_id: Role.find_by_name(Role::SUPER_ADMIN).try(:id))
  end

  def standard_users
    self.users.where.not(role_id: Role.find_by_name(Role::SUPER_ADMIN).try(:id))
  end

  def followers_count
    self.company_followers.count
  end

  def opened_jobs_count
    self.jobs.active.count
  end

  def is_follow_by_user user
    !user.nil? && user.is_jobseeker? && !CompanyFollower.find_by(company_id: self.id, jobseeker_id: user.jobseeker.id).nil?
  end

  def company_owner
    self.users.where(role_id: Role.find_by_name(Role::SUPER_ADMIN).try(:id)).first
  end

  # the following code to group job_applications by sector of jobseeker & country of jobseeker
  # Group applications of appliers to this company by sector
  def job_applications_by_sector
    JobApplication.get_applications_of_company_group_by_sector(self)
  end

  # Group applications of appliers to this company by country
  def job_applications_by_country
    JobApplication.get_applications_of_company_group_by_country(self)
  end

  # Group applications of appliers to this company by nationality
  def job_applications_by_nationality
    JobApplication.get_applications_of_company_group_by_nationality(self)
  end


  # Group applications of appliers to this company by age group
  def job_applications_by_age_group
    JobApplication.get_applications_of_company_group_by_age_group(self)
  end


  # Group applications of appliers to this company by education
  def job_applications_by_education
    JobApplication.get_applications_of_company_group_by_education(self)
  end

  def job_applications_by_gender
    JobApplication.get_applications_of_company_group_by_gender(self)
  end


  # Group followers of company by country
  def followers_by_country
    Jobseeker.get_followers_of_company_group_by_country(self)
  end


  # Group followers of company by country
  def followers_by_nationality
    Jobseeker.get_followers_of_company_group_by_nationality(self)
  end


  # this method return hash with {year: followers_count} for all users which follow company & depend on birthdate
  def followers_by_age
    User.get_followers_of_company_group_by_age(self)
  end

  # the following to upload avatar & cover images
  def upload_avatar new_avatar
    self.avatar = new_avatar
    self.save!
  end

  # the following to upload management video
  def upload_management_video new_video
    self.upload_video new_video,'video_our_management','video_our_management'
  end

  def upload_cover new_cover

    # Checking if the upload file is a video
    if new_cover.content_type.include? 'video'
      self.upload_video new_cover,'cover','video_cover'
    else
      self.cover = new_cover
      self.save!
    end
  end

  def city_name
    self.current_city.try(:name)
  end

  def country_name
    self.current_country.try(:name)
  end

  # This method to change in DB
  def self.switch_two_companies old_company_id, new_company_id
    old_company = Company.find_by_id(old_company_id)
    new_company = Company.find_by_id(new_company_id)
    if old_company && new_company
      old_company.company_followers.update_all(company_id: new_company_id)
      old_company.jobs.update_all(company_id: new_company_id)

      old_company.destroy
    end
  end

  def avatar_url
    avatar.url(:original)
  end

  def cover_url
    cover.url(:original)
  end

  def frontend_path
    "companies/#{self.name.parameterize}-#{self.id}"
  end

#   TODO: This for copy old avatars
  UploadAvatar = Struct.new(:company, :avatar_local_path) do
    def perform
      company.avatar = File.open(avatar_local_path)
      company.save
    end
  end
end
