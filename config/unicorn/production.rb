# config/unicorn.rb
# Set environment to development unless something else is specified
require 'socket'
hostname = Socket.gethostname
app_name = 'supportbee_app'

env = "production"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 10

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
#listen "/tmp/my_site.socket", :backlog => 64

# Preload our app for more speed
preload_app true
#user 'rails', 'rvm'

# nuke workers after 30 seconds instead of 60 seconds (the default)
#timeout 180
listen "10.1.1.1:3000" if hostname == 'web1'
listen "10.1.1.3:3000" if hostname == 'web2'
listen "127.0.0.1:3000"

WORKING_DIR = "/home/rails/apps/supportbee_app/current"
SHARED_DIR = "/home/rails/apps/supportbee_app/shared"
working_directory WORKING_DIR
PID_PATH = "#{SHARED_DIR}/pids/unicorn.#{hostname}.pid"
pid PID_PATH
stderr_path "#{SHARED_DIR}/log/unicorn.#{hostname}.stderr.log"
stdout_path "#{SHARED_DIR}/log/unicorn.#{hostname}.stdout.log"

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{PID_PATH}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
