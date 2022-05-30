namespace :cleaning do
  # TODO: Remove this code, if no need
  desc 'clean up all avatar images'
  task clean_all_user_avatar: :environment do
    User.where.not(avatar_content_type: nil).each do |user|
      user.avatar = nil
      user.save
    end
  end


  desc 'clean up all video images'
  task clean_all_user_video_and_screenshot: :environment do
    User.where.not(video_content_type: nil, video_screenshot_content_type: nil).each do |user|
      user.video = nil
      user.video_screenshot = nil
      user.save
    end
  end

  desc 'clean up all documents in certificate'
  task clean_all_document_certificates: :environment do
    JobseekerCertificate.where.not(document_content_type: nil).each do |jobseeker_certificate|
      jobseeker_certificate.document = nil
      jobseeker_certificate.save
    end
  end

  desc 'clean up all documents in education'
  task clean_all_document_educations: :environment do
    JobseekerEducation.where.not(document_content_type: nil).each do |jobseeker_education|
      jobseeker_education.document = nil
      jobseeker_education.save
    end
  end

  desc 'clean up all documents in experience'
  task clean_all_document_experiences: :environment do
    JobseekerExperience.where.not(document_content_type: nil).each do |jobseeker_experience|
      jobseeker_experience.document = nil
      jobseeker_experience.save
    end
  end

  desc 'clean up all documents in resumes'
  task clean_all_document_resumes: :environment do
    JobseekerResume.where.not(document_content_type: nil).each do |jobseeker_resume|
      jobseeker_resume.document = nil
      jobseeker_resume.save
    end
  end

  desc 'clean up all documents in coverletters'
  task clean_all_document_coverletters: :environment do
    JobseekerCoverletter.where.not(document_content_type: nil).each do |jobseeker_coverletter|
      jobseeker_coverletter.document = nil
      jobseeker_coverletter.save
    end
  end
end