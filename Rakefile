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

task :build_graph do
  require_relative './app'
  require_relative './lib/build_graph'

  puts "Building graph"
  build_graph
  puts "Complete!"
end

def run(dir)
  Dir[dir].each { |file| load file }
end
