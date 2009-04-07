#############################################################
#	Application
#############################################################

set :application, "badi2010"
set :deploy_to, "/var/rails/#{application}" # NOT /var/www/...

#depend :local,  :gem, "xyz"
#depend :remote, :gem, "xyz"

#############################################################
#	Remote command execution setup
#############################################################

default_run_options[:pty] = true
set :use_sudo, false  # deploying to a debian machine
set :runner, "kreba"
# set :user,  "kreba"
# set :group, "rails"

#############################################################
#	Servers
#############################################################

set :domain, "badifraubrunnen.ch"
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	Version Control System
#############################################################

# depend :remote,  :command, "hg"  # checked by the hg plugin

# Make the repository available for the target host with
# 'hg serve --port 8007 --daemon' (in the project directory)

set :scm, :mercurial
set :scm_user, "Raffael Krebs <kreba@gmx.ch>"
set :repository, "http://novocrab.crabnet:8007/"
#set :scm_checkout, "export"  # nonetheless 'clone' is used!?!

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -snf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
after 'deploy:update_code', 'deploy:symlink_shared'

#############################################################
#	Passenger (overrides the default restart task)
#############################################################

namespace :deploy do
  desc "Tell Passenger to restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end



