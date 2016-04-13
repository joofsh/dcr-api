load './tasks/db.rake'

task default: :test

desc 'Shotgun for API developing'
task :server do
  exec 'shotgun -p 4000'
end

desc 'Rackup for faster client developing'
task :rackup do
  exec 'rackup -p 4000 -s webrick'
end

task :test do
  run "test/**/*_test.rb"
end

task :console do
  exec 'pry -r ./app'
end

def run(dir)
  Dir[dir].each { |file| load file }
end
