%:
	cd .. && make $@

install:
	[[ -z $${CI} ]] || sh scripts/prebuilt_macros.sh unzip
	bundle exec pod install --verbose

spm.fetch:
	bundle exec pod spm fetch --all --verbose

spm.prebuild:
	bundle exec pod spm prebuild --all --verbose

build:
	sh scripts/xcodebuild.sh

test:
	env XCODEBUILD_ACTION=test sh scripts/xcodebuild.sh
