#!/bin/bash

set -e
#commented by laxman
cur_dir=`dirname $0`

#cur_dir=$PWD/scripts/ios

echo "current-direction $cur_dir"

#Check if ios-app keychain exists
export keychainCount=`security list-keychains | grep -E 'ios-app' -c`

if [ $keychainCount == 0 ] ; then
 echo "Create ios-app keychain"
 # Create a custom keychain
 security create-keychain -p "ios-app-password" ios-app.keychain
fi
# Add it to the list
security list-keychains -d user -s ios-app.keychain

echo "Making the ios-app keychain default, so xcodebuild will use it for signing"
security default-keychain -s ios-app.keychain

echo "Unlocking the ios-app keychain"
security unlock-keychain -p "ios-app-password" ios-app.keychain

# Set keychain timeout to 1 hour for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 36000 -l ~/Library/Keychains/ios-app.keychain

echo "Importing $IOS_CERTIFICATE to keychain"
security import $cur_dir/certs/$IOS_CERTIFICATE -k ~/Library/Keychains/ios-app.keychain -P "" -T "/usr/bin/codesign" -A

#Mac OS Sierra https://stackoverflow.com/questions/39868578/security-codesign-in-sierra-keychain-ignores-access-control-settings-and-ui-p
security set-key-partition-list -S apple-tool:,apple: -s -k "ios-app-password" ios-app.keychain

# Put the provisioning profile in place
echo "Copying $IOS_PROVISION_PROFILE in place"
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "$cur_dir/profile/$IOS_PROVISION_PROFILE" ~/Library/MobileDevice/Provisioning\ Profiles/