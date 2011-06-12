Enjoy this Fibonacci function until I get my site finished
{% highlight python %}
def fib(num):
  if (num <= 2):
    return 1
  else:
    return fib(num - 1) + fib(num - 2)

print fib(10)
{% endhighlight %}