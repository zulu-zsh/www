build:
	roots compile

publish:
	git fetch origin
	git checkout gh-pages
	git reset --hard $${TRAVIS_COMMIT:-'master'}
	make build
	cd public
	git init
	git remote add origin https://molovo:$${GH_TOKEN}@github.com/zulu-zsh/index.git
	git add .
	git commit -m 'Deploy compiled site'
	# Hide output of push, as access token is printed
	git push --force origin master >/dev/null 2>&1
	git checkout master
