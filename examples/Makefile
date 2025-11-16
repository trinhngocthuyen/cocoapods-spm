%:
	cd .. && make $@

install:
	xcodebuild -version
	sh scripts/prebuilt_macros.sh unzip
	bundle exec pod install --verbose --ansi

spm.fetch:
	bundle exec pod spm macro fetch --all --verbose

spm.prebuild:
	bundle exec pod spm macro prebuild --all --verbose

build:
	sh scripts/xcodebuild.sh

test:
	env XCODEBUILD_ACTION=test sh scripts/xcodebuild.sh
