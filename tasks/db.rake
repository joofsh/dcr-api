def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end

namespace :db do
  task :environment do
    require_relative '../app'
    Sequel.extension :migration

    DB_NAME = ENV["API_DB_NAME"]
  end

  desc "performs db migration up to latest available"
  task :migrate, [:version] => [:environment] do |t, args|
    envs = development? ? ['development', 'test'] : ['production']
    envs.each do |env|

      silence_warnings do
        DB_CONFIG[:database] = database_name(env)
        DB = Sequel.connect(DB_CONFIG)
      end

      p "Checking migration status for: #{env}"
      if args[:version]
        Sequel::Migrator.run(DB, "migrations", target: args[:version].to_i)
      else
        Sequel::Migrator.run(DB, "migrations")
      end
      Rake::Task['db:version'].execute
    end
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
  task :kill_postgres_connections do
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
    #DB.disconnect
    #DB << "CREATE DATABASE #{DB_NAME} CHARACTER SET utf8;"
    cmd = %(createdb '#{DB_NAME}')

    unless system(cmd)
      fail $?.inspect
    end
    puts "Database #{DB_NAME} created"
  end

  desc "Reset database and load test data"
  task :reset => [:environment] do
    #Rake::Task['db:kill_postgres_connections'].execute
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:test_data'].execute

  end

  desc "Load test data"
  task :test_data => [:environment] do
    require './dummy_data'

    puts 'Creating test data'
    build_dummy_data
    puts 'Complete'
  end
end
