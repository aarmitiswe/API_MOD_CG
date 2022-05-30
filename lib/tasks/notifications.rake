namespace :mapper do

  desc 'map notifications for jobseekers'
  task notifications_jobseekers: :environment do
    table_name = 'notifications'
    records    = extract_data('jobseekernotifications')
    records.each do |r|
      user         = User.find_by_id(r[:userid])
      unless user.nil?
        notification = Notification.create({
                                            id: r[:notificationid],
                                            user_id: r[:userid],
                                            blog: r[:articles],
                                            poll_question: 0,
                                            job: r[:jobs]
                                        })
      end
    end
    set_max_ids(table_name)
  end

  desc 'map notifications for employers'
  task notifications_employers: :environment do
    table_name = 'notifications'
    records    = extract_data('employernotifications')
    records.each do |r|
      user         = User.find_by_id(r[:userid])
      unless user.nil?
        notification = Notification.create({
                                            blog: r[:articles],
                                            user_id: r[:userid],
                                            poll_question: 0,
                                            job: r[:jobs]
                                        })
        # Set default value weekly notification for employer
        notification.update_attribute(:candidate, 2) if user.is_employer?
      end
    end
    set_max_ids(table_name)
  end

  desc 'Execute all notifications'
  task notifications: :environment do
    Rake::Task['mapper:notifications_jobseekers'].execute
    Rake::Task['mapper:notifications_employers'].execute
  end
end
