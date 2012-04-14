---
layout: post
title: The HTTP OPTIONS method
---
The OPTIONS method is a somewhat obscure part of the HTTP standard that I believe could be used today with little effort but could have a strong impact on the interconnectedness of the interwebs. It's role is well defined in [RFC2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html), yet no web services that I can find are taking advantage of it.

## What is the HTTP OPTIONS method?

To quote the spec:

> This method allows the client to determine the options and/or requirements associated with a resource, or the capabilities of a server, without implying a resource action or initiating a resource retrieval.

The response should be a 200 OK and have an `Allows` header with a list of HTTP methods that may be used on this resource. So, as an authorized user on an API, if you were to request `OPTIONS /users/me`, you should receive something like 

    200 OK
    Allows: HEAD,GET,PUT,DELETE,OPTIONS

## (Almost) no one uses it

I've tested quite a few sites and APIs and so far, the only resources I've found that respond properly are default Apache pages. Specifically, directory indices. If you try it on apache.org/dist/httpd, for example, you'll get a response like this:

    ...
    Server: Apache/2.4.1 (Unix) OpenSSL/1.0.0g
    Allow: GET,HEAD,POST,OPTIONS,TRACE
    Content-Type: httpd/unix-directory
    ...

GitHub responds with a 500, Reddit with `501 Not Implemented`, Google maps with `405 Method Not Allowed`. You get the idea. I've tried many others, and the results are usually similar. Sometimes it yields something identical to a GET response. None of these are right.

GitHub (to pick on someone specific. Not because I don't love you!) could be using this to tell me what I am allowed to do with each resource exposed by their endpoints. And before you tell me "meh, it's just a list of HTTP verbs you can use on a resource. Who cares?" let me throw some more of the RFC your way.

## The response body and API documentation

> The response body, if any, SHOULD also include information about the communication options. The format for such a body is not defined by this specification, but might be defined by future extensions to HTTP.

It could be an HTML page with documentation, but that's sort of unpractical, because users don't click the "get options" button in their browsers before visiting a page. Machines may though.

APIs should be taking advantage of this. There are many benefits to be gained from producing machine readable docs at every endpoint. It would boon for automatic client generation for web services. Communication between web services could be much more resilient if they had a codified way to check their abilities against each other.

At the very least, services should be responding with a 200 and the Allows header. That's just correct web server behavior. But there's really no excuse for JSON APIs not to be returning a documentation object. To use GitHub as example again, on the issues endpoint, a request like `OPTIONS /repos/:user/:repo/issues` should respond with a body like...

{% highlight javascript %}
  {
    "POST": {
      "description": "Create an issue",
      "parameters": {
        "title": {
          "type": "string"
          "description": "Issue title.",
          "required": true
        },
        "body": {
          "type": "string",
          "description": "Issue body.",
        },
        "assignee": {
          "type": "string",
          "description" "Login for the user that this issue should be assigned to."
        },
        "milestone": {
          "type": "number",
          "description": "Milestone to associate this issue with."
        },
        "labels": {
          "type": "array/string"
          "description": "Labels to associate with this issue."
        }
      },
      "example": {
        "title": "Found a bug",
        "body": "I'm having a problem with this.",
        "assignee": "octocat",
        "milestone": 1,
        "labels": [
          "Label1",
          "Label2"
        ]
      }
    }
  }
{% endhighlight %}

Of course, it'd show more than just the paramters for the POST method. I'd like to see a standardized format for documentation like this, but developing that is not the point of this post.

## Advancing our tools
I'm currently working on a small, one page Sinatra, MongoDB, Backbone.js app. Every endpoint will respond to the OPTIONS method. As I go, I'm extracting it into a gem to make self-explaining Sinatra APIs easy. I'd like to participate in disucssion about this being added to Rails routing. At least responding with a proper Allows header would be a start. I'm also interested in exploring the automatically generated client idea via Backbone apps.

In the mean time, I just want to get the discussion started because I think there's a lot of potential here and I'm surprised that no one has tapped into it yet. As _RESTful Web Services_ puts it, "OPTIONS is a promising idea that nobody uses."
