set :application,       'zacstewart.com'
set :repository,        'git@github.com:zacstewart/zacstewart.com.git'
set :scm,               :git
set :deploy_via,        :copy
set :branch,            "master"
set :copy_compression,  :gzip
set :use_sudo,          false
set :host,              'zacstewart.com'

role :web,  host
role :app,  host
role :db,   host, :primary => true
ssh_options[:port] = 22

# this forwards your agent, meaning it will use your public key rather than your
# dreamhost account key to clone the repo. it saves you the trouble of adding that
# key to github
ssh_options[:forward_agent] = true

set :user,    'zacstewart'
set :group,   user

set(:dest) { Capistrano::CLI.ui.ask("Destination: ") }

if dest == 'dev'
  set :deploy_to,    "/home/#{user}/dev.#{application}"
elsif dest == 'www'
  set :deploy_to,    "/home/#{user}/#{application}"
end

namespace :deploy do

  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t, :roles => :app do ; end
  end

  # compile compass and then jekyll
  # you need to execute absolute paths here, so `which jekyll` to figure out what exactly you should run
  task :finalize_update do
    run "/bin/bash -c 'source ~/.bash_profile; cd #{latest_release}; /home/zacstewart/.rvm/gems/ruby-1.9.2-p180/bin/compass compile -c config_prod.rb --force; /home/zacstewart/.rvm/gems/ruby-1.9.2-p180/bin/jekyll;'"
  end
end