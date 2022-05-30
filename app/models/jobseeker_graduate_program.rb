class JobseekerGraduateProgram < ActiveRecord::Base
  include SendInvitation

  belongs_to :jobseeker

  after_update :send_reject_mail_template


  has_attached_file :ielts_document, dependent: :destroy

  validates_attachment_content_type :ielts_document, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]


  has_attached_file :toefl_document, dependent: :destroy

  validates_attachment_content_type :toefl_document, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  CRITERIA_GRADUATE_PROGRAM = {
      min_score_ielts: 4,
      min_score_toefl: 4,
      min_gpa_bachelors: 4,
      min_gpa_master: 3,
      max_age_bachelors: 25,
      max_age_master: 32,
      nationality_id: Country.find_by_name("Saudi Arabia").id,
  }

  # Comment code may be required. Graduate program validate on  english certificate
  # scope :matched_criteria, -> { where("(ielts_score >= ? OR toefl_score >= ?) AND ((bachelor_gpa >= ? AND age <= ?) OR (master_gpa >= ? AND age <= ?)) AND nationality_id = ?",
  #                                     CRITERIA_GRADUATE_PROGRAM[:min_score_ielts], CRITERIA_GRADUATE_PROGRAM[:min_score_toefl],
  #                                     CRITERIA_GRADUATE_PROGRAM[:min_gpa_bachelors], CRITERIA_GRADUATE_PROGRAM[:max_age_bachelors],
  #                                     CRITERIA_GRADUATE_PROGRAM[:min_gpa_master], CRITERIA_GRADUATE_PROGRAM[:max_age_master],
  #                                     CRITERIA_GRADUATE_PROGRAM[:nationality_id]) }
  #
  #
  # def is_matched_criteria?
  #   (self.ielts_score.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_score_ielts] ||
  #       self.toefl_score.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_score_toefl]) &&
  #       ((self.bachelor_gpa.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_gpa_bachelors] && self.age.to_f <= CRITERIA_GRADUATE_PROGRAM[:max_age_bachelors]) ||
  #       (self.master_gpa.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_gpa_master] && self.age.to_f <= CRITERIA_GRADUATE_PROGRAM[:max_age_master])) &&
  #       (self.nationality_id.to_i == CRITERIA_GRADUATE_PROGRAM[:nationality_id])
  # end

  scope :matched_criteria, -> { where("((bachelor_gpa >= ? AND age <= ?) OR (master_gpa >= ? AND age <= ?)) AND nationality_id = ?",
                                      CRITERIA_GRADUATE_PROGRAM[:min_gpa_bachelors], CRITERIA_GRADUATE_PROGRAM[:max_age_bachelors],
                                      CRITERIA_GRADUATE_PROGRAM[:min_gpa_master], CRITERIA_GRADUATE_PROGRAM[:max_age_master],
                                      CRITERIA_GRADUATE_PROGRAM[:nationality_id]) }



  scope :not_matched_criteria, -> {where.not(jobseeker_id: JobseekerGraduateProgram.matched_criteria.pluck(:jobseeker_id))}

  def is_matched_criteria?
         ((self.bachelor_gpa.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_gpa_bachelors] && self.age.to_f <= CRITERIA_GRADUATE_PROGRAM[:max_age_bachelors]) ||
        (self.master_gpa.to_f >= CRITERIA_GRADUATE_PROGRAM[:min_gpa_master] && self.age.to_f <= CRITERIA_GRADUATE_PROGRAM[:max_age_master])) &&
        (self.nationality_id.to_i == CRITERIA_GRADUATE_PROGRAM[:nationality_id])
  end

  def apply_for_graduate_job
    self.jobseeker.job_applications.find_or_create_by(job_id: Job.find_by_title('graduate_program').id)
  end

  def unapply_for_graduate_job
    # self.jobseeker.job_applications.find_by_job_id(Job.find_by_title('graduate_program').id).try(:destroy)
  end

  def send_reject_mail_template
    if self.jobseeker.complete_step >= 4
      if !self.is_matched_criteria?
        if self.rejection_sent_at.nil?
          self.unapply_for_graduate_job
        end
      else
        self.apply_for_graduate_job
      end
    end
  end
end
