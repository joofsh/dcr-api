require 'sequel'

Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :association_dependencies
#Sequel::Model.plugin :polymorphism

Sequel::Model.raise_on_save_failure = false
Sequel.default_timezone = :utc

def database_name(env = nil)
  db_name = ENV['API_DB_NAME']
  db_name += '_test' if env == 'test'
  db_name
end

DB_CONFIG = {
  adapter:  ENV['API_DB_ADAPTER'],
  host:      ENV['API_DB_HOST'],
  database:  database_name,
  user:      ENV['API_DB_USER'],
  password:  ENV['API_DB_PASSWORD'],
  servers: {}
}

DB ||= Sequel.connect(DB_CONFIG)

DB.extension :null_dataset

