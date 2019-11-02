# Set the build number to the count of Git commits
infoPlist="./BitURL/Info.plist"
buildNumber=$(git rev-list HEAD | wc -l | tr -d ' ')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" $infoPlist