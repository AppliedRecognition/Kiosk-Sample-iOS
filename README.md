# Kiosk Sample App for iOS

## About
The app continuously runs face detection in the background. When a user steps in front of the camera the app starts a Ver-ID liveness detection session. After the session finishes the app asks the user to step away from the camera and make way for another user.

## Prerequisites
- Xcode 11
- [CocoaPods](https://cocoapods.org)

## Installation
1. Clone this project.
2. Navigate to the project folder in Terminal, type `pod install` and press enter.
3. Open the newly-generated **Kiosk Sample.xcworkspace** in Xcode.