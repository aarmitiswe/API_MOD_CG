namespace :mapper do
  # TODO: Change paths

  desc 'map upload profile images for users'
  task upload_profile_images_users: :environment do
    User.where.not(profile_image: nil).where(avatar_content_type: nil).each do |user|
      avatar_path = Rails.root.join('../bloovo.com', "uploads/ProfileImage/Large/#{user.profile_image}")
      next if !File.exists?(avatar_path)
      Delayed::Job.enqueue User::UploadAvatar.new(user, avatar_path)
    end
  end

  desc 'map upload profile images for companies'
  task upload_profile_images_companies: :environment do
    Company.where.not(profile_image: nil).where(avatar_content_type: nil).each do |company|
      avatar_path = Rails.root.join('../bloovo.com', "uploads/company/320x128/#{company.profile_image}")
      next if !File.exists?(avatar_path)
      Delayed::Job.enqueue Company::UploadAvatar.new(company, avatar_path)
    end
  end

  desc 'Upload profile_videos && Profile_video_screenshots'
  task upload_profile_videos: :environment do
    Jobseeker.where.not(profile_video: nil, profile_video_image: nil).each do |jobseeker|
      video_path = Rails.root.join('../bloovo.com',"uploads/ProfileVideo/#{jobseeker.profile_video}")
      video_screenshot_path = Rails.root.join('../bloovo.com', "uploads/ProfileVideo/Thumb/#{jobseeker.profile_video_image}")
      if File.exists?(video_path)
        Delayed::Job.enqueue User::UploadVideo.new(jobseeker.user, video_path) if jobseeker.user
      end

      if File.exists?(video_screenshot_path)
        Delayed::Job.enqueue User::UploadVideoScreenshot.new(jobseeker.user, video_screenshot_path) if jobseeker.user
      end
    end
  end

  desc 'link with videos'
  task link_to_videos: :environment do
    Jobseeker.where.not(profile_video: nil, profile_video_image: nil).each do |jobseeker|
      user = jobseeker.user
      av = user.video.options
      url = "http://s3.amazonaws.com/#{av[:s3_credentials][:bucket]}/videos_users/#{user.id.to_s(36)}_#{user.created_at.to_i.to_s(36)}"
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri.path)
        print "#{user.id} is Done\n"
        if response.code == "200"
          user.video = uri
          user.save!
        end
      end

      url = "http://s3.amazonaws.com/#{av[:s3_credentials][:bucket]}/video_screenshots/#{user.id.to_s(36)}_#{user.created_at.to_i.to_s(36)}"
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri.path)
        print "#{user.id} is Done\n"
        if response.code == "200"
          user.video_screenshot = uri
          user.save!
        end
      end
    end
  end

  desc 'upload document for jobseeker_resumes'
  task upload_document_resumes: :environment do
    JobseekerResume.where.not(file_path: nil).where(document_file_name: nil).each do |jobseeker_resume|
      resume_path = Rails.root.join('../bloovo.com', "uploads/Resume/#{jobseeker_resume.file_path}")
      if File.exists?(resume_path)
        Delayed::Job.enqueue JobseekerResume::UploadDocument.new(jobseeker_resume, resume_path)
      end
    end
  end

  desc 'link with resumes'
  task link_to_resumes: :environment do
    JobseekerResume.where(document_file_name: nil).each do |jobseeker_resume|
      av = jobseeker_resume.document.options
      url = "http://s3.amazonaws.com/#{av[:s3_credentials][:bucket]}/documents_jobseeker_resumes/#{jobseeker_resume.id.to_s(36)}_#{jobseeker_resume.created_at.to_i.to_s(36)}"
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri.path)
        print "#{jobseeker_resume.id} is Done\n"
        if response.code == "200"
          jobseeker_resume.document = uri
          jobseeker_resume.save!
        end
      end
    end
  end

  desc 'upload document for jobseeker_coverletters'
  task upload_document_coverletters: :environment do
    JobseekerCoverletter.where.not(file_path: nil).where(document_file_name: nil).each do |jobseeker_coverletter|
      coverletter_path = Rails.root.join('../bloovo.com', "uploads/Cover/#{jobseeker_coverletter.file_path}")
      if File.exists?(coverletter_path)
        Delayed::Job.enqueue JobseekerCoverletter::UploadDocument.new(jobseeker_coverletter, coverletter_path)
      end
    end
  end

  desc 'upload document for jobseeker_certificate'
  task upload_document_certificates: :environment do
    JobseekerCertificate.where.not(attachment: nil).where(document_file_name: nil).each do |jobseeker_certificate|
      certificate_path = Rails.root.join('../bloovo.com', "uploads/Certificates/#{jobseeker_certificate.attachment}")
      if File.exists?(certificate_path)
        Delayed::Job.enqueue JobseekerCertificate::UploadDocument.new(jobseeker_certificate, certificate_path)
      end
    end
  end

  desc 'upload document for jobseeker_experience'
  task upload_document_experiences: :environment do
    JobseekerExperience.where.not(attachment: nil).where(document_file_name: nil).each do |jobseeker_experience|
      experience_path = Rails.root.join('../bloovo.com', "uploads/UserWork/#{jobseeker_experience.attachment}")
      if File.exists?(experience_path)
        Delayed::Job.enqueue JobseekerExperience::UploadDocument.new(jobseeker_experience, experience_path)
      end
    end
  end

  desc 'upload document for jobseeker_education'
  task upload_document_educations: :environment do
    JobseekerEducation.where.not(attachment: nil).where(document_file_name: nil).each do |jobseeker_education|
      education_path = Rails.root.join('../bloovo.com', "uploads/EduCertificates/#{jobseeker_education.attachment}")
      if File.exists?(education_path)
        Delayed::Job.enqueue JobseekerEducation::UploadDocument.new(jobseeker_education, education_path)
      end
    end
  end

  desc 'upload document for blogs'
  task upload_avatar_blogs: :environment do
    Blog.where.not(image_file: nil).where(avatar_file_name: nil).each do |blog|
      news_path = Rails.root.join('../bloovo.com',"uploads/News/798x384/#{blog.image_file}")
      article_path = Rails.root.join('../bloovo.com',"uploads/Article/798x384/#{blog.image_file}")
      file_path = File.exists?(news_path) ? news_path : article_path
      if File.exists?(file_path)
        Delayed::Job.enqueue Blog::UploadAvatar.new(blog, file_path)
      end
    end
  end

  desc 'map all jobseeker data'
  task uploader: :environment do
    Rake::Task['mapper:upload_profile_images_users'].execute
    Rake::Task['mapper:upload_profile_videos'].execute
    Rake::Task['mapper:upload_document_resumes'].execute
    Rake::Task['mapper:upload_document_coverletters'].execute
    Rake::Task['mapper:upload_document_certificates'].execute
    Rake::Task['mapper:upload_document_experiences'].execute
    Rake::Task['mapper:upload_document_educations'].execute
    Rake::Task['mapper:upload_avatar_blogs'].execute
    Rake::Task['mapper:upload_profile_images_companies'].execute
  end
end