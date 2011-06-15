---
layout: post
---
I've finally gotten around to doing something with my domain. I'm becoming quite the Git junkie
these days, and I prefer to spend most of my time between my text editor and a terminal, so I
started myself a Jekyll blog. I took the idea of using my favorite TextMate theme for colors from
my friend Stafford (thanks!). I may rework the layout a bit, I'm not sure I'm feeling this dark
one so much.

Anyway, I've gotten Jekyll working on my shared Dreamhosting account, and not just pushing the
compiled pages to my webroot: compiling my Sass stylesheets and then compiling the static HTML
pages with Jekyll and even using Pygments to generate syntax-aware HTML--all server-side.

Why did I go through all the trouble? I see this blog as source code. I didn't want to distribute
a binary. I wanted the source to be what I kept in my repo, and to compile the blog you're reading
right now from it.

But, without further ado, here's what I did to make that happen:

# Install RVM
RVM is great for keeping multiple Ruby environments organized. It's also easy to install in your
home directory and run without root permissions. I was having trouble installing Jekyll on my
Dreamhost account, as the version of Ruby on the system didn't support it. Instinctively, I ran
`sudo gem update --system`. Oh, right, not in the sudoers file and this incident just
got reported.

There's more detailed instructions at the [RVM installation](http://beginrescueend.com/rvm/install/ "RVM installation")
page, but this is the gist:

{% highlight bash %}
  $ bash < <(curl -s https://rvm.beginrescueend.com/install/rv m)
  $ echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile
  $ source .bash_profile
  $ rvm install 1.9.2 # or any other current version
  $ rvm use 1.9.2 --default
{% endhighlight %}

You can test that it's working with `ruby -v`, which should yield something like `ruby 1.9.2p180 (2011-02-18 revision 30909) [x86_64-linux]`.

# Install Jekyll with Pygments for Syntax Highlighting
Getting Jekyll is easy: just `gem install jekyll`. If you want syntax highlighting for code blocks
you need to do a little more work, though. `easy_install Pygments` won't work. I played on
[this guide](http://tatey.com/2009/04/29/jekyll-meets-dreamhost-automated-deployment-for-jekyll-with-git/ "Jekyll Meets DreamHost. Automated Deployment For Jekyll With Git")
but updated it for a more recent version of Pygments.

## Configure your Python Environment
{% highlight bash %}
  $ mkdir ~/lib/python
  $ echo 'export PYTHONPATH="$HOME/lib/python:/usr/lib/python2.3"' >> ~/.bash_profile
  $ source ~/.bash_profile
{% endhighlight %}

## Get and Build Pygments
{% highlight bash %}
  $ cd ~/src
  $ wget http://pypi.python.org/packages/source/P/Pygments/Pygments-1.4.tar.gz
  $ tar -xvzf Pygments-1.4.tar.gz
  $ cd Pygments-1.4
  $ python setup.py install --home=$HOME
{% endhighlight %}

Make sure `PATH=$PATH:~/packages/bin/:~/bin` is in your .bash_profile, if not, add it
and then run `source ~/.bash_profile`. Check that it's working be running `pygmentize`.

# Setup Capistrano and Deploy!
So, I'm assuming that you're using GitHub with this guide, but you can probably figure it out
if you're not. Maybe later I'll have a post on getting [Gitosis](http://scie.nti.st/2007/11/14/hosting-git-repositories-the-easy-and-secure-way "Gitosis") working on Dreamhost (once I
have it working well myself).

I found this [Simple Capistrano recipe for Jekyll](https://gist.github.com/286293), but had to do a
little work on it. Especially since I'm using [Compass](http://compass-style.org) on my blog.

## config/deploy.rb
{% highlight ruby %}
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
{% endhighlight %}

Of course, you'll need to configure it with your credentials and if you, like me, are using
compass, you'll need to change your compile task. Add ` ~/.rvm/gems/ruby-1.9.2-p180/bin/compass';`
__before__ running jekyll.

You should be all ready to deploy now. Commit your changes, push your repo and then run `cap deploy`

***

This post is actually the first wherein I have all this set up, so I've undoubtedly made
mistakes here. If you have something to improve, by all means, fork this blog and fix it!
I'd love to accept a pull request.