---
layout: post
title: Defining Abilities for Collections of Records Using CanCan
---
I've been using [CanCan](https://github.com/ryanb/cancan) for managing
role-based authorization in [Rstrnt](http://rstrnt.net), my restaurant
management solution. CanCan is a very simple and easy-to-use
authorization library that works out-of-the-box with Devise (and any
other authentication system that provides a current_user method).
However I had a use case that doesn't seem to be documented on the
project's wiki.

# The Special Case
I wanted to authorize a user on a collection of records, for example on
the index action of a controller. The typical way to do this is to
define your abilities using hash conditions and then query for the records
that a user may access using `accessible_by(current_ability)`. This felt
icky to me, though. I didn't want CanCan so deeply ingrained into my
app. I have my own logic for which records to request, and while at some
point I may decide to let all the logic reside within my Ability model,
right now I don't want to.

So, in this example, I'm working with a `Restaurant`, `current_membership`
(my own permission-role system. For the purposes of this example,
consider it equivalent to `current_user`) and many instances of
`TimeOffRequest`. I want managers and admins to have access to all the
restaurant's time off requests, but other users should only have access
to their own. The following logic is actually enough to ensure that
they're only ever requesting within those parameters, but I still want
to `authorize!` them to be sure. Projects tend to become increasingly
complex and I want to make sure that at no point in the future I do
something that accidentally gives access to someone undeserving. Having
all that bottleneck through the Ability model helps me sleep at night.

{% highlight ruby %}
  # time_off_requests_controller.rb
  if current_membership.has_any_role?(:admin, :manager)
    @time_off_requests = @restaurant.time_off_requests
  else
    @time_off_requests = current_membership.time_off_requests
  end
{% endhighlight %}

# `Authorize!` those records!
Usually you do something like `authorize! :read, @time_off_request` to
make sure a user can indeed read the time off request in question.
However, with an array of time off requests, it gets tricky. Your first
instinct, like mine, may be to just call `authorize! :read,
@time_off_requests`. This won't work, though. Your Ability model depends
upon the type of object you pass it. In this case, you would be passing
it an Array and not a TimeOffRequest. You could, I suppose, define an
ability for Array and then do some funky work inside there to figure out
what kind of array it is, and go from there... But that would be a
horrible solution.

## Enter the splat: `*`
What you need, is a way to evaluate an entire collection of
TimeOffRequests, but you must pass the first argument as an instance
thereof and not an array. That's where the handy ol' splat comes in.
In the example below, the asterisk in `*time_off_requests` means that
the block will accept N number of arguments and will squish them back
into an array, letting me use an iterative method on it, in this case `all?`.

{% highlight ruby %}
  # Ability.rb
  can :manage, TimeOffRequest do |*time_off_requests|
    membership.has_any_role?(:admin, :manager) ||
      time_off_requests.all? { |tor| membership.id == tor.employee_id }
  end
{% endhighlight %}

## Back in the controller...
Now I just need to call `authorize!` properly. The splat operator also lets
you pass the contents of an array as arguments. If you're from the PHP
world you may recognize the similarity of `call_user_func_array`.

{% highlight ruby %}
  foo = [:a, :b, :c]
  bar(*foo)
  # is the same as
  bar(:a, :b, :c)
{% endhighlight %}

There is one bit of inelegance that I don't like here. As I said
earlier, CanCan needs the argument following the access method to be an
instance of the class you are authorizing. An empty array splat means no
arguments. So if `@time_off_requests` is empty, which is completely
possible, CanCan will raise an exception for too few arguments. I got
around this by using ternary operator to always pass at least a new
instance.

# The Code

{% highlight ruby %}
  # time_off_requests_controller.rb
  def index
    if current_membership.has_any_role?(:admin, :manager)
      @time_off_requests = @restaurant.time_off_requests
    else
      @time_off_requests = current_membership.time_off_requests
    end

    authorize! :read, *(@time_off_requests.any? ? @time_off_requests : current_membership.time_off_requests.new)
    respond_to do |format|
      format.html
    end
  end
{% endhighlight %}

{% highlight ruby %}
  # Ability.rb
  can :manage, TimeOffRequest do |*time_off_requests|
    membership.has_any_role?(:admin, :manager) ||
      time_off_requests.all? { |tor| membership.id == tor.employee_id }
  end
{% endhighlight %}
