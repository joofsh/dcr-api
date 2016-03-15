ENV["RACK_ENV"] = 'test'

require_relative '../app'

require 'rack/test'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'database_cleaner'
require_relative 'assert_helpers'

require_relative 'spawner'

Minitest::Reporters.use!
DatabaseCleaner.strategy = :transaction

Minitest.after_run do
  DB.tables.select { |t| t.to_s != 'schema_info' }.each do |table|
    DB << "TRUNCATE TABLE #{table} CASCADE"
  end
end

$TEST_COUNTER = 0

def random_id
  $TEST_COUNTER += 1
end

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    EhrApiV1
  end

  def body
    @body ||= JSON.parse last_response.body, symbolize_names: true
  end

  def status
    last_response.status
  end

  def user_url(path, user = current_user)
    token = Token.find_or_create(user.id).value
    header "Authorization", "Bearer #{token}"
    path
  end

  def current_user
    @current_user ||= Advocate.spawn!
  end

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end
