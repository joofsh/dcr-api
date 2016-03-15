load './tasks/db.rake'

task default: :server

task :server do
  exec 'shotgun -p 4000'

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
