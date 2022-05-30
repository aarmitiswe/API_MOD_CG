class Country < ActiveRecord::Base
  include Pagination

  # validates :iso, presence: true, uniqueness: {case_sensitive: true}, length: {is: 2,
  #                                                                              message: 'should be 2 characters'}
  validates :name, presence: true, uniqueness: {case_sensitive: true}

  has_many :cities
  has_many :users
  has_many :jobs
  has_many :country_geo_groups
  has_many :geo_groups, through: :country_geo_groups

  scope :order_by_alphabetical, -> {  order("name ASC") }
  scope :order_by_jobs, -> {  joins("LEFT OUTER JOIN jobs ON jobs.country_id = countries.id")
                                  .where("jobs.active = ? AND jobs.deleted = ? AND jobs.job_status_id = ? AND jobs.start_date <= '#{Date.today.strftime('%Y-%m-%d')}'::date AND jobs.end_date >= '#{Date.today.strftime('%Y-%m-%d')}'::date", true, false, 2)
                                  .group("countries.id").order("count(jobs.id) DESC") }
  scope :order_by_jobs_all, -> {  joins("LEFT OUTER JOIN jobs ON jobs.country_id = countries.id AND jobs.active = true AND jobs.deleted = false AND jobs.job_status_id = 2 AND jobs.start_date <= '#{Date.today.strftime('%Y-%m-%d')}'::date AND jobs.end_date >= '#{Date.today.strftime('%Y-%m-%d')}'::date")
                                  .group("countries.id").order("count(jobs.id) DESC") }

end
