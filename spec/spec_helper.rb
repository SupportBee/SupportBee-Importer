require File.expand_path(File.dirname(__FILE__) + "/../app")
require 'sinatra'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
	config.mock_with :flexmock
	config.before :each do
		upload_path = File.expand_path(APP_CONFIG['mail_storage_dir'])
		FileUtils.remove_dir(upload_path, true) if File.exists?(upload_path)
		FileUtils.mkpath(upload_path)
	end
end