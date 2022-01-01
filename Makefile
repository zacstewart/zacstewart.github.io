build: *
	bundle install
	bundle exec jekyll build

deploy: build
	cd build && \
		remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \
		remote_branch="gh-pages" && \
		git init && \
		git config user.name "${GITHUB_ACTOR}" && \
		git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
		git add . && \
		echo -n 'Files to Commit:' && ls -l | wc -l && \
		git commit -m'Deploy to GitHub pages' 2>&1 && \
		git push --force $remote_repo master:$remote_branch > /dev/null 2>&1 && \
		rm -rf .git && \
		cd ..
