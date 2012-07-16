Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }
require './app'
run SupportBee::Importer