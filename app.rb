require 'bundler'
require 'dotenv'
Dotenv.load
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

def development?
  ENV['RACK_ENV'] == 'development'
end

def test?
  ENV['RACK_ENV'] == 'test'
end

require './config/db'

Dir['./lib/**/*.rb'].each { |file| require file }
Dir['./models/**/*.rb'].each { |file| require file }

class EhrApiBase < Roda
  use Rack::PostBodyContentTypeParser
  use Rack::MethodOverride
  include AuthHelpers
  include CRUDHelpers
  include HaltHelpers

  plugin :all_verbs
  plugin :default_headers, 'Content-Type'=>'application/json'
  plugin :drop_body
  plugin :json, :classes=>[Array, Hash, Sequel::Model]
  plugin :halt
  plugin :error_handler do |e|
    error = {
      exception: {
        error: e.class,
        details: e.message,
        backtrace: e.backtrace
      }
    }
    p e.message
    e.backtrace.each { |b| p b }
    error
  end

  def params
    @_request.params
  end
end

Dir['./routes/**/*.rb'].each { |file| require file }

class EhrAPI < EhrApiBase
  route do |r|
    r.on 'resources' do
      r.run ResourceRoutes
    end

    r.on 'users' do
      r.run UserRoutes
    end

    r.on 'tags' do
      r.run TagRoutes
    end

    r.on 'wizard' do
      r.run WizardRoutes
    end

    r.on 'demo' do
      r.run DemoRoutes
    end

    r.on 'config' do
      r.run ConfigRoutes
    end

    r.on 'questions' do
      r.run QuestionRoutes
    end
  end
end
