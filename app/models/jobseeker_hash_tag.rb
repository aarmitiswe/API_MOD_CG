class JobseekerHashTag < ActiveRecord::Base
  belongs_to :jobseeker
  # belongs_to :hash_tag, inverse_of: :jobseeker_hash_tags
  belongs_to :hash_tag
  # has_one :hash_tag
  # accepts_nested_attributes_for :hash_tag, allow_destroy: true

  validates_presence_of :jobseeker, :hash_tag
  validates_uniqueness_of :jobseeker_id, scope: :hash_tag_id

  #
  def self.create_bulk jobseeker_id, hash_tags
    hash_tags.each do |hash_tag|
      hash_tag_id = hash_tag[:id]
      hash_tag_id = HashTag.create(name: hash_tag[:name]).id if hash_tag[:id].nil?
      if hash_tag[:_destroy]
        JobseekerHashTag.where(jobseeker_id: jobseeker_id, hash_tag_id: hash_tag_id).destroy_all
      else
        JobseekerHashTag.create(jobseeker_id: jobseeker_id, hash_tag_id: hash_tag_id)
      end
    end
  end
end
