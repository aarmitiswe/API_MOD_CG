class CareerFair < ActiveRecord::Base
  include Pagination

  has_attached_file :logo_image, dependent: :destroy

  validates_attachment_content_type :logo_image, content_type: [
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"
  ]

  belongs_to :country
  belongs_to :city
  has_many :career_fair_applications, dependent: :destroy
  scope :deleted, -> {where( deleted: true)}
  scope :active, -> {where( deleted: false)}
  scope :live, -> {where("deleted = false AND career_fairs.from <= (?) AND career_fairs.to >= (?)", Date.today, Date.today)}


  def applied_date user
    return nil if user.nil?
    jobseeker = user.jobseeker
    self.career_fair_applications.find_by(jobseeker_id: jobseeker.id).try(:created_at) unless jobseeker.nil?
  end
end
