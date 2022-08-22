#!/bin/bash
set -e
cur_dir=`dirname $0`

echo "current direction: $cur_dir"

WORKING_DIR=`pwd`;
cd $cur_dir/../../ios
echo "Setting version to ${BUILD_NUMBER}, ${BUILD_NAME}"
xcrun agvtool new-version -all ${BUILD_NUMBER}
xcrun agvtool new-marketing-version ${BUILD_NAME}
cd $WORKING_DIR

security unlock-keychain -p "ios-app-password" ios-app.keychain

echo "Archiving the project"
#arch --x86_64 xcodebuild clean archive -allowProvisioningUpdates PRODUCT_BUNDLE_IDENTIFIER="com.changiairport.cagapp3.uat" -project $cur_dir/../../ios/${PROJECT_NAME}.xcodeproj -destination 'generic/platform=iOS' -scheme $IOS_SCHEME -configuration $IOS_CONFIGURATION -derivedDataPath $cur_dir/../../ios/build -archivePath $cur_dir/../../ios/build/Products/${PROJECT_NAME}.xcarchive

# or if you are not using xcodeproj and are using xcworkspace to build.. use the below code:

# echo "Archiving the project"
arch --x86_64 xcodebuild clean archive PRODUCT_BUNDLE_IDENTIFIER="com.changiairport.cagapp3.uat" -workspace $cur_dir/../../ios/${PROJECT_NAME}.xcworkspace -scheme $IOS_SCHEME -destination 'generic/platform=iOS' -derivedDataPath $cur_dir/../../ios/build -archivePath $cur_dir/../../ios/build/Products/${PROJECT_NAME}.xcarchive

#below line is for testing
#arch --x86_64 xcodebuild clean archive PRODUCT_BUNDLE_IDENTIFIER="com.changiairport.cagapp3.uat" -workspace $cur_dir/../../ios/${PROJECT_NAME}.xcworkspace -scheme $IOS_SCHEME -destination 'generic/platform=iOS' Provisioning_Profile="CNX Tigerspike UAT" Development_Team="Q73U6GYWJC"  -derivedDataPath $cur_dir/../../ios/build -archivePath $cur_dir/../../ios/build/Products/${PROJECT_NAME}.xcarchive

    
#SIGN
# Issue : "No applicable devices found."
# Fix: https://stackoverflow.com/questions/39634404/xcodebuild-exportarchive-no-applicable-devices-found
unset GEM_HOME
unset GEM_PATH

echo "Export archive to create IPA file using $IOS_EXPORT_OPTIONS_PLIST"
arch --x86_64 xcodebuild -exportArchive -archivePath $cur_dir/../../ios/build/Products/${PROJECT_NAME}.xcarchive -exportOptionsPlist $cur_dir/../../scripts/ios/exportOptions/$IOS_EXPORT_OPTIONS_PLIST -exportPath $cur_dir/../../ios/build/Products/IPA

echo "IPA will be found at $cur_dir/../../ios/build/Products/IPA/$IOS_SCHEME.ipa"