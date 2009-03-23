require 'mongrel_cluster/recipes'

set :application, "badi2010"
set :server_url, "www.badifraubrunnen.ch"
set :repository,  "http://drunkencrab/repos/trunk/#{application}"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/rails/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
#set :use_sudo, true
set :runner, "kreba"
#set :user, "xy" # set the user on the deployment machines ("remote user account name")
#set :runner, :user # set the sudo runner user to whatever the connecting user is 

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
# set :svn, "/usr/bin/svn"
set :deploy_via, :export  #default is 'checkout' ('export' omits .svn files)

role :app, "#{server_url}"
role :web, "#{server_url}"
role :db,  "#{server_url}", :primary => true

depend :local, :command, "svn"
depend :remote, :command, "svn"
depend :remote, :gem, "gem_plugin"
depend :remote, :gem, "mongrel"
depend :remote, :gem, "mongrel_cluster"

before "deploy:restart", :restart_web_server

task :restart_web_server, :roles => :web do
  #sudo "/etc/init.d/apache2 restart"
end