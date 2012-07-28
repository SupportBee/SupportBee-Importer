# Production cap file

set :rvm_ruby_string, '1.9.3-p194' # Defaults to 'default'
server "reminderhawk.com", :app, :web, :db, :primary => true
set :repository,  "git@github.com:SupportBee/SupportBee-Importer.git"

