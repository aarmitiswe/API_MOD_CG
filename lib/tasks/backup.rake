# Simple database backup rake task using mysqldump
namespace :backup do
  desc "Backup database"
  task :db do
    RAILS_ENV = "production" if !defined?(RAILS_ENV)
    app_root = File.join(File.dirname(__FILE__), "..", "..")

    settings = YAML.load(File.read(File.join(app_root, "config", "database.yml")))[RAILS_ENV]
    output_file = File.join(app_root, "..", "backup", "#{settings['database']}-#{Time.now.strftime('%Y%m%d')}.sql")

    # system("/usr/bin/env mysqldump -u #{settings['username']} -p#{settings['password']} #{settings['database']} > #{output_file}")
    # -W #{settings['password']}
    command = "/usr/bin/env PGPASSWORD=\"#{settings['password']}\" pg_dump --no-acl --no-owner -h #{settings['host'] || 'localhost'} -U #{settings['username']} -p #{settings['port'] || 5432} -d #{settings['database']} > #{output_file}"
    puts command
    system(command)
  end
end