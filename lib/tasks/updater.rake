def update_field_with_s3_filename(objectClass, field_name = 'document_s3_path', file_path = 'document')

  current_page = 1
  files_per_page = 1000
  totalobjects = objectClass.paginate(page: current_page, per_page: files_per_page)
  total_pages_objects = totalobjects.total_pages
  while current_page <= total_pages_objects && totalobjects.size > 0 do

    totalobjects.each do |selObject|
      selObject.send('update_column', field_name.to_sym, selObject.send(file_path.to_sym).url.split('/').last)
    end
    puts "#{objectClass} Page #{current_page} completed"
    current_page += 1
    totalobjects = objectClass.paginate(page: current_page, per_page: files_per_page)
  end
  puts "Done #{objectClass}"
end

namespace :updater do
  desc 'Update Auth Token'
  task update_auth_token: :environment do
    (1000..500000).step(1000).each do |max_id|
      puts "Start in #{max_id}"
      User.where("id > ? AND id <= ?", (max_id-1000), max_id).each do |user|
        user.password = 'Test@1234'
        user.password_confirmation = 'Test@1234'
        user.generate_authentication_token!
        user.save(validate: false)
      end
      puts "End in #{max_id}"
    end
  end


  desc 'Update from s3 files'
  task update_from_s3_files: :environment do

    #Resume
     update_field_with_s3_filename(JobseekerResume, 'document_s3_path', 'document')
    # Coverletter
     update_field_with_s3_filename(JobseekerCoverletter, 'document_s3_path', 'document')
    # Certificate
     update_field_with_s3_filename(JobseekerCertificate, 'document_s3_path', 'document')
    # JobseekerExperience
     update_field_with_s3_filename(JobseekerExperience, 'document_s3_path', 'document')
    # JobseekerEducation
     update_field_with_s3_filename(JobseekerEducation, 'document_s3_path', 'document')
    # User Avatar
     update_field_with_s3_filename(User, 'avatar_s3_path', 'avatar')
    # User Video
     update_field_with_s3_filename(User, 'video_s3_path', 'video')

    puts "File names updated from S3"
  end

end


