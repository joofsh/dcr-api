ENV['RACK_ENV'] = 'test'

require_relative '../app'

# Load mock services
Dir['./test/services/*.rb'].each { |file| require file }

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
    EhrAPI
  end

  def post(uri, data = {}, opts = {})
    @body = nil
    if opts[:upload]
      super(uri, data, opts)
    else
      super(uri, data.to_json, opts)
    end
  end

  def put(uri, data = {}, *opts)
    @body = nil
    super(uri, data.to_json, *opts)
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
    header "Content-Type", "application/json"
    header "Accept", "application/json"
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end
