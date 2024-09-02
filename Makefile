REMOTE_BRANCH="gh-pages"
REMOTE_REPO="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

build: _site

_site: *
	bundle install
	bundle exec jekyll build

deploy: _site
	cd _site && \
		touch .nojekyll && \
		git init && \
		git config user.name "${GITHUB_ACTOR}" && \
		git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
		git add . && \
		echo -n 'Files to Commit:' && ls -l | wc -l && \
		git commit -m'Deploy to GitHub pages' 2>&1 && \
		git push --force ${REMOTE_REPO} master:${REMOTE_BRANCH} > /dev/null 2>&1 && \
		rm -rf .git && \
		cd ..
