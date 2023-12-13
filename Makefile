install:
	which pre-commit &> /dev/null || brew install pre-commit
	pre-commit install
	bundle install

format:
	pre-commit run --all-files

test:
	bundle exec rspec

ex.install:
	cd ../ios-demos/cocoapods-spm && bundle exec pod install --verbose
