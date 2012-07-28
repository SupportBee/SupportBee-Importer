# Production cap file

#server "supportbee.com", :app, :web, :db, :primary => true
role :app, "web1.supportbee.com", "web2.supportbee.com"
role :db, "db1.supportbee.com"
set :repository,  "git@github.com:prateekdayal/SupportBee-Rails.git"
set :branch, "stable"

