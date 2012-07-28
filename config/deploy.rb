require 'rvm/capistrano'
require 'capistrano/ext/multistage'

set :default_stage, 'staging'

# Campfire
require 'capistrano/campfire'

# Fix from https://github.com/capistrano/capistrano/issues/168
Capistrano::Configuration::Namespaces::Namespace.class_eval do
  def capture(*args)
    parent.capture *args
  end
end

set :campfire_options, :account => 'supportbee',
                       :room => 'SupportBee',
                       :token => '3b6227280f2699d4a85144e131bfe73ee85581ba',
                       :ssl => true

set :application, "supportbee_importer"

set :deploy_to, "/home/rails/apps/#{application}"

# Server is defined in stage specific file
set :user, 'rails'    

set :rvm_type, :system
set :scm, "git"
set :ssh_options, { :forward_agent => true }

set :rvm_type, :system
#set :rvm_ruby_string, '1.9.3-p194' # Defaults to 'default'

set :deploy_via, :remote_cache

set :use_sudo,  false

# Hooks to do specific stuff
after "deploy:update_code", "supportbee_importer:config", 
                            "bundler:bundle_new_release",
                            "supportbee_importer:symlink"
                            #"supportbee_importer:brew_js",
                            #"supportbee_importer:migrate_and_seed",
                            #"supportbee_importer:generate_css",
                            #"supportbee_importer:generate_assets"

after "deploy", "deploy:cleanup", 
                "campfire:after_deployment"

#after "deploy:restart", "supportbee_importer:restart_bluepill"

before "deploy", "campfire:start_deployment"

namespace(:deploy) do
  task :restart, :roles => :app do
    run <<-CMD
      /etc/init.d/unicorn_supportbee_importer restart 
    CMD
  end
end

namespace(:campfire) do
  task :start_deployment do
    campfire_room.speak "[Deployment] #{ENV['USER']} is preparing to deploy #{application} to #{stage}" 
  end

  task :after_deployment do 
    campfire_room.speak "[Deployment] #{ENV['USER']} finished deploying #{application} to #{stage}" 
  end
end
    
namespace(:supportbee_importer) do

  task :config do
    %w(sb_config.yml).each do |file|
      run <<-CMD
        ln -nfs #{shared_path}/system/#{file} #{release_path}/config/#{file}
      CMD
    end
  end

  task :symlink do
    #run <<-CMD
      #ln -nfs #{shared_path}/assets/uploads #{release_path}/uploads
    #CMD

    run <<-CMD
      rm #{release_path}/public/system
    CMD
  end
end

namespace :bundler do
  task :create_symlink do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, 'vendor', 'bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test development cucumber --deployment"
  end
  
  task :lock do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock do
    run "cd #{current_release} && bundle unlock;"
  end
end


