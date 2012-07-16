require 'sinatra/base'
require 'sinatra-initializers'
require 'json'

module SupportBee
  class Importer < Sinatra::Base
  
    register Sinatra::Initializers

    set :root, File.dirname(__FILE__)

    post '/mailgun_mime' do
      puts params
      "OK"
    end
  
    run! if app_file == $0
  end
end