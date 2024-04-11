ensure.pre-commit:
	which pre-commit &> /dev/null || pip install pre-commit

install: ensure.pre-commit
	pre-commit install
	bundle install

format: ensure.pre-commit
	pre-commit run --all-files

test:
	bundle exec rspec

ci.install:
	bundle install

ex.install:
	cd examples && make install

ex.test.%:
	cd examples && \
		make install test LINKAGE=$$(echo $@ | cut -d. -f3)

ex.test:
	make ex.test.static # Default to static

ex.test.all:
	make ex.test.static
	make ex.test.dynamic
