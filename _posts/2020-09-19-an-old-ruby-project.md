---
layout: post
title: "Coming Back to an Old Ruby Project After a Few Years"
---
I have this Ruby project that I haven't worked on in while. Over the last four
or five years I've barely committed any work, just enough to keep it humming
along.  It has actual users (not that many though) and has hundreds of pages
indexed by search engines. It's just an open source community thing, not super
important. I've been so lazy with it that a feature branch that I never merged
with into has been running in production for years. Since it's Saturday and I
don't have anything to do (thanks global pandemic), I decided to rectify that
and finally clean this project up.

It's been a while and I've actually switched to a new machine since the last
time I touched it.  Thanks to TimeMachine, my home directory is more or less a
clone of what it was last time, though.  The Gemfile said Ruby 2.3.0.  I still
had that version installed, apparently, so I switched to it using my version
manager.  The entire bundle of gems is installed too. Convenient.  I ran `rake
test` just to see if everything still works.  Sadly, there's a litany of
dynamically linked libraries that my Ruby executable was compiled against and
are now missing.  That's fair. My home directory is a clone, but /usr/bin/local
has probably changed significantly with Homebrew upgrades and what-have-you.  I
decided to blow away my Ruby installation and start with a fresh build using
install-ruby. That seemed to go well.

Well, kind of. Ruby 2.3.0 compiled and installed fine. IRB started up and worked
fine.  But, I couldn't run `bundle`. OpenSSL was missing.  I've run into
problems like this before and I can't point to exactly what, but I vaguely
recollect having a bad time. The gist in my memory is that if something targets
an old version of OpenSSL: 1) It's far, far behind on security updates and 2)
you're SOL to install it unless you want to start installing long-forgotten
versions of OpenSSL by following sketchy advice littered across comments on
GitHub issues left by people similarly marooned by bit rot.  Fuck that. How
about I just upgrade to the latest Ruby version?  There's nothing super fancy
in this project and whatever syntax changes have occurred between Ruby 2.3.0
and now should be minimal right?  I used to be an ardent Rubyist but I haven't
been following things for years now since I work primarily in other languages.
Occasionally I see controversy over new syntax changes but don't really dig in.
I just don't care that much. I don't plan to use Ruby in the future and I've
kinda lost interest.  I installed the latest version (2.7.1) and indicated such
in the Gemfile.  Right off the bat, Bundler complained that Bundler
1.7.something isn't available.  Weird. Bundler says Bundler isn't available.
It suggested that I install some specific version of Bundler, so I did.

That helps. Almost everything installed when I ran `bundle install`. Not json
version 1.8.3, though.  There are some details in the error message about
rb_cFixnum and rb_cBignum symbols being missing. That sounds like the release
note for Ruby 2.4.0. They dropped those two to unify under `Integer` Who even
needs to install json? Isn't this part of the standard lib? I can't remember.
The dependency chain says dm-serializer wants it, and data_mapper wants that.
Why the hell did I use DataMapper on this project anyway? Maybe I didn't want
to go through the frustration of figuring out how to use ActiveModel divorced
from Rails.  This is just a small Sinatra web app with a bunch of POROs to
ingest events from a websocket and stick them in a database.  Maybe there is
some incremental version of json that is compatible with both dm-serializer and
these changes in Ruby 2.4.0.  Looks like dm-serializer 1.2.2 depends on json ~>
1.6 (that ~> syntax means the 6 can go upwards, so hypothetically 1.7, 1.8,
1.9, etc. would be fine).  I ran `bundle update json` to let it figure out an
optimal version to make everyone happy. It chose 1.8.6. It looks like that the
last of the ruby 1.x line.  There we go, `bundle install` finished
successfully.

I ran `rake test` just to see if everything works.  Nope. Now Ruby tells me it
can't import dm-serializer because there is a conflict between the json version
1.8.6 that it wants and another version, 2.3.0.  Who the hell wants json 2.3.0
and why are they both installed?  There's no mention of this version in my
Gemfile.lock so it appears no one wants it.  I tried to uninstall it myself
with gem.  Hmm, can't do that. Apparently it's a default gem. Is that like U2's
Songs of Innocence?  Okay, so how about any updates to dm-serializer that can
address this situation?  No. No commits for like the past nine years.  I knew
DataMapper was basically a dead project when I adopted it, so that's on me.
Looks like there's something called ardm that seeks to hijack DataMapper names
and make them more flexible with dependencies.  I tried replacing all the gems
required by data_mapper with ardm-prefixed gems. No dice.  Half of these
fictitious libraries don't exist, replacing those with actual dm-gems leads to
conflicts.  I'm just making a mess at this point.

I ran git reset to undo all this scrambling. I've been through two cups of
coffee. Saturday morning is now Saturday afternoon and I'm hungry for lunch. It
can't be this hard.

So, I have this Ruby project that I haven't worked on in while.
