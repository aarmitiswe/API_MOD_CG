require 'smarter_csv'
require 'date'
require 'pp'

require 'helpers/data_converter'

namespace :mapper do

  desc 'Execute all migration commands in a specific order'
  task all: :environment do
    Rake::Task['mapper:locations'].execute
    Rake::Task['mapper:generic_tables'].execute
    Rake::Task['mapper:users_data'].execute
    Rake::Task['mapper:companies_data'].execute
    Rake::Task['mapper:poll_data'].execute
    Rake::Task['mapper:jobseeker'].execute
    Rake::Task['mapper:all_jobs'].execute
    Rake::Task['mapper:notifications'].execute
    Rake::Task['mapper:all_blogs'].execute
    Rake::Task['mapper:companies_followers'].execute
    Rake::Task['mapper:uploader'].execute
  end

end
