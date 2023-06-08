include .env

BUILD_DIR := Build
BASE_NAME := SamplePlugin
WORKSPACE := $(BASE_NAME).xcworkspace
BUNDLE_NAME := $(BASE_NAME)Bundle

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -rf .build

.PHONY: bundle/build
bundle/build:
	xcodebuild -workspace $(WORKSPACE) -scheme $(BUNDLE_NAME) -destination 'platform=macOS,arch=arm64' -configuration Release -derivedDataPath ./$(BUILD_DIR)/Bundle build

.PHONY: bundle/cp
bundle/cp:
	cp -r $(BUILD_DIR)/Bundle/Build/Products/Release/$(BUNDLE_NAME).bundle $(UNITY_PLUGIN_MACOS_DIR)/$(BUNDLE_NAME).bundle

.PHONY: bundle
bundle: clean bundle/build bundle/cp

.PHONY: framework/build
framework/build:
	mint run swift-create-xcframework --output ./$(BUILD_DIR)/Framework --platform ios --configuration release

.PHONY: framework/cp
framework/cp:
	cp -r ./$(BUILD_DIR)/Framework/$(BASE_NAME).xcframework/ios-arm64/$(BASE_NAME).framework $(UNITY_PLUGIN_IOS_DIR)/$(BASE_NAME).framework

.PHONY: framework
framework: clean framework/build framework/cp
