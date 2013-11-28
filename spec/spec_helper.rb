
require 'rubygems'

$:.push File.expand_path('../../lib', __FILE__)

require 'active_model'
require 'activemodel_phone'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each{|f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end
