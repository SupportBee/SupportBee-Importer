require './app'
require 'exceptional'
use Rack::Exceptional, '5ba40a12ca0a18e0dc3f6348395c33cb66c9915e' if SupportBee::Importer.environment == 'production'
run SupportBee::Importer