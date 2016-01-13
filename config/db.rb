require 'sequel'

Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :association_dependencies
#Sequel::Model.plugin :polymorphism

Sequel::Model.raise_on_save_failure = false
Sequel.default_timezone = :utc

DB_CONFIG = {
  adapter:  ENV['API_DB_ADAPTER'],
  host:      ENV['API_DB_HOST'],
  database:  ENV['API_DB_NAME'],
  user:      ENV['API_DB_USER'],
  password:  ENV['API_DB_PASSWORD'],
  servers: {}
}

DB ||= Sequel.connect(DB_CONFIG)

