require 'mina/deploy'
require 'mina/git'
require 'mina/bundler'
require 'mina/rbenv'
require 'mina/puma'

set :application_name, 'image_iptimizer_web'
set :domain, '88.99.226.18'
set :deploy_to, '/home/optimizer/app'
set :repository, 'git@github.com:airled/image_optimizer_web.git'
set :branch, 'master'
set :user, 'optimizer'
set :shared_dirs, fetch(:shared_dirs, []).push('public/downloads', 'node_modules', 'tmp', 'log')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

task :environment do
  invoke :'rbenv:load'
end

task :setup do
  in_path(fetch(:shared_path)) do
    command %{mkdir -p tmp/sockets}
    command %{mkdir -p tmp/pids}
  end
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
      invoke :'npm_install'
      invoke :'asset_compile'
      invoke :'puma:phased_restart'
    end
  end
end

task :npm_install do
  in_path(fetch(:current_path)) do
    command "echo '-----> Installing dependencies using npm'"
    command %{npm install}
  end
end

task :asset_compile do
  in_path(fetch(:current_path)) do
    command "echo '-----> Compiling assets using webpack'"
    command %{./node_modules/webpack/bin/webpack.js}
  end
end
