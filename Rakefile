load './tasks/db.rake'

task default: :server

task :server do
  exec 'shotgun -p 4000'

end

task :console do
  exec 'pry -r ./app'
end
