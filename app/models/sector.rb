require 'fuzzy_match'

class Sector < ActiveRecord::Base
  include Pagination

  has_many :jobs

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :order_by_display, -> {  order("display_order ASC") }
  scope :order_by_alphabetical, -> {  order("name ASC") }

  scope :order_by_jobs, -> {  joins("LEFT JOIN jobs ON jobs.sector_id = sectors.id")
                                  .where("jobs.active = ? AND jobs.deleted = ? AND jobs.job_status_id = 2 AND jobs.start_date <= '#{Date.today.strftime('%Y-%m-%d')}'::date AND jobs.end_date >= '#{Date.today.strftime('%Y-%m-%d')}'::date", true, false)
                                  .group("sectors.id").order("count(jobs.id) DESC") }
  scope :order_by_jobs_all, -> {  joins("LEFT JOIN jobs ON jobs.sector_id = sectors.id AND jobs.active = true AND jobs.deleted = false AND jobs.job_status_id = 2 AND jobs.start_date <= '#{Date.today.strftime('%Y-%m-%d')}'::date AND jobs.end_date >= '#{Date.today.strftime('%Y-%m-%d')}'::date")
                                  .group("sectors.id").order("count(jobs.id) DESC") }

  def similar_sectors
    FuzzyMatch.new(Sector.order(:display_order), read: :name).find_all_with_score(self.name).map{ |arr| arr[0...arr.count - 2]}.flatten
  end

  def get_jobs_count
    self.jobs.active.count
  end
end
