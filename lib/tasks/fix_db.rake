namespace :fix_db do
  task :fix_auto_increment => :environment do
    ActiveRecord::Base.connection.tables.each do |table|
      unless table == "schema_migrations"
        result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
        if result.any?
          ai_val = result.first['id'].to_i + 1
          puts "Resetting auto increment ID for #{table} to #{ai_val}"
          seq = ActiveRecord::Base.connection.execute("SELECT count(*) count FROM #{table}_id_seq")
          unless seq.any?
            ActiveRecord::Base.connection.execute("CREATE SEQUENCE #{table}_id_seq START #{ai_val}")
          end
          ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
          ActiveRecord::Base.connection.execute("ALTER TABLE #{table} ALTER COLUMN id SET DEFAULT nextval('#{table}_id_seq');")
        else
          ai_val = 1
          puts "Resetting auto increment ID for #{table} to #{ai_val}"
          seq = ActiveRecord::Base.connection.execute("SELECT count(*) count FROM #{table}_id_seq")
          unless seq.any?
            ActiveRecord::Base.connection.execute("CREATE SEQUENCE #{table}_id_seq START #{ai_val}")
          end

          ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
          ActiveRecord::Base.connection.execute("ALTER TABLE #{table} ALTER COLUMN id SET DEFAULT nextval('#{table}_id_seq');")
        end
      end
    end
  end
end
