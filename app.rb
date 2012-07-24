Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }

require 'sinatra/base'
require 'sinatra-initializers'

module SupportBee
  class Importer < Sinatra::Base
  
    register Sinatra::Initializers

    set :root, File.dirname(__FILE__)
    set :raise_errors, true
    set :logging, true
    set :dump_errors, true

    get '/' do
      "OK"
    end

    post '/mailgun_mime' do
      puts params
    	mailgun = SupportBee::Mailgun.new(params)
    	begin
      	mailgun.import
      rescue Exception => e
      	Exceptional.context(:backup_filename => mailgun.backup_filename)
      	Exceptional.handle(e, "MAILGUN IMPORT FAILED: #{SupportBee::Importer.environment} ")
      	mailgun.backup
      end
      "OK"
    end
  
    run! if app_file == $0
  end
end