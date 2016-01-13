require 'rack/contrib'
require 'sinatra/base'
require 'shield'
require 'sinatra/namespace'
require 'sinatra/json'
require 'json'

def development?
  ENV['RACK_ENV'] == 'development'
end

require 'dotenv'
Dotenv.load

if development?
  require 'pry'
  require 'awesome_print'
end

require './config/db'


Dir['./lib/**/*.rb'].each { |file| require file }
Dir['./models/**/*.rb'].each { |file| require file }

class EhrApiBase < Sinatra::Base
  use Rack::PostBodyContentTypeParser
  register Sinatra::Namespace
  include AuthHelpers
  include CRUDHelpers
  include HaltHelpers
end

Dir['./routes/**/*.rb'].each { |file| require file }

class EhrApiV1 < EhrApiBase
  use UserRoutes
end
