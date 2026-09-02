# chat

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Requirement

`Flutter 3.32.2`
`Dart 3.8.1`
`DevTools 2.45.1`

# Generate rest_client with retrofit generator

`flutter pub run build_runner build`
`dart run build_runner build --delete-conflicting-outputs`

# Clean and run Project

rm -rf build
./gradlew --stop
./gradlew clean

# == for apple case ==

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# == for apple case ==

# Error flutter_app_badger

- remove package="fr.g123k.flutterappbadge.flutterappbadger" in AndroidManifest.xml (in cache lib flutter app_badger)
- add namespace "com.example.flutter_app_badger" in build.gradle -> android { namespace "com.example.flutter_app_badger" } (in cache lib flutter app_badger)
- set targetSdkVersion 33
  android {
  compileSdkVersion 33 // Set this to at least 31

        defaultConfig {
            minSdkVersion 21
            targetSdkVersion 33
        }

  }

# Build & Run

- `flutter run`
