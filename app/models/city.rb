class City < ActiveRecord::Base
  include Pagination
  belongs_to :country
  has_many :jobs

  scope :order_by_alphabetical, -> {  order("name ASC") }
  # TODO: Add not expired jobs "end_date > ?", Date.today .where("jobs.active = ? AND jobs.job_status_id = ?", true, 2)
  scope :order_by_jobs, -> {  joins("LEFT JOIN jobs ON jobs.city_id = cities.id AND jobs.active = true AND jobs.job_status_id = 2")
                                  .group("cities.id").order("count(jobs.id) DESC") }

end
