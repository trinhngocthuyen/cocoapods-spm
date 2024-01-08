ensure.pre-commit:
	which pre-commit &> /dev/null || pip install pre-commit

install: ensure.pre-commit
	pre-commit install
	bundle install

format: ensure.pre-commit
	pre-commit run --all-files

test:
	bundle exec rspec

ex.install:
	cd examples && make install
