namespace :db do
  task :environment do
    require './app'
    Sequel.extension :migration

    DB_NAME = ENV["API_DB_NAME"]
  end

  desc "performs db migration up to latest available"
  task :migrate, [:verison] => [:environment] do |t, args|
    if args[:version]
      Sequel::Migrator.run(DB, "migrations", target: args[:version].to_i)
    else
      Sequel::Migrator.run(DB, "migrations")
    end
    Rake::Task['db:version'].execute
  end

  desc "print db version"
  task :version => [:environment] do
    begin
      version = DB[:schema_info].first[:version]
      puts "Schema Version for #{DB_NAME}: #{version}"
    rescue Sequel::DatabaseError
      puts "Schema Undefined. Please Migrate"
    end
  end

  desc 'kills all connections to postgres db'
  task :kill_postgres_connections do#=> [:environment] do
    cmd = %(psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'ehr';" -d 'ehr')

    unless system(cmd)
      fail $?.inspect
    end
  end

  desc "drop the database"
  task :drop => [:environment] do
    DB.disconnect
    #DB << "DROP DATABASE \"#{DB_NAME}\";"
    cmd = %(dropdb '#{DB_NAME}')

    unless system(cmd)
      fail $?.inspect
    end
    puts "Database #{DB_NAME} dropped"
  end

  desc "create the database"
  task :create => [:environment] do
    DB.disconnect
    #DB << "CREATE DATABASE #{DB_NAME} CHARACTER SET utf8;"
    cmd = %(createdb '#{DB_NAME}')

    unless system(cmd)
      fail $?.inspect
    end
    puts "Database #{DB_NAME} created"
  end

  task :reset => [:environment] do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute

    User.create(username: 'joofsh', email: 'foo@bar.com', role: 'admin', password: 'foobar')
  end
end
