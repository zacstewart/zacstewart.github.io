# zacstewart.com

This is the source that generates my site. If you're here because you found a
typo, error, or other discrepancy in my writing, please open an issue or,
better yet, send me a pull request.

# Writing

1. Write new post (preferably in Markdown) in a file with the following naming convention:

    _posts/yyyy-mm-dd-short-title-of-post.md

2. Build site to make sure the post is valid: `jekyll build`
3. Commit new post `git commit _posts/yyyy-mm-dd-short-title-of-post.md`
4. Deploy by pushing to origin/master: `git push origin master`

# Updating the site layout

* Make any stylesheet changes to the .scss files in _sass/_. See changes by
  running `compass compile` or `compass watch`. `compass compile -e production`
  when you're happy with the changes. The files in _css/_ are only included
  becasuse GitHub Pages doesn't compile sass.
* Change layout partials in _\_layouts_
* Add new pages by creating files in the root directory
* Add any new files that shouldn't be served to visitors to the exclude list in
  _\_config.yml_
* Build site to make sure change are valid: `jekyll build` or `jekyll serve`
* Make sure you've compiled and commited the css files and then push to
  origin/master: `git push origin master`
