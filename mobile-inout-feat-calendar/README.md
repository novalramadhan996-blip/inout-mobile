# mobile_in_out

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Requirement

`Flutter 3.32.2`
`Dart 3.8.1`
`DevTools 2.45.1`

# auto_route_generator

`Create auto route`

- `flutter pub run build_runner build`
  `Cleaning route`
- `flutter pub run build_runner clean`
- `flutter pub run build_runner build --delete-conflicting-outputs`

# Flutter Icon

- `flutter pub run flutter_launcher_icons`

# Clean Architecture Riverpod

- data/datasource/remote_datasource (for set api url and get response for api)
- domain/repositories/repository (abstract class repository)
- data/repositories/repository (class repository)
- domain/provider/provider (provider)

# First Config

# Background Location

- on MacBook open path /Users/phincon/.pub-cache/hosted/pub.dev/background_location-0.13.0/android/build.gradle
  add namespace = "com.almoullim.background_location"

# Error Tensor

'UnmodifiableUint8ListView' isn't defined for the class 'Tensor'.
Modify on file C:/Users/adefa/AppData/Local/Pub/Cache/hosted/pub.dev/tflite_flutter-0.10.4/lib/src/tensor.dart
change from :
return UnmodifiableUint8ListView(
data.asTypedList(tfliteBinding.TfLiteTensorByteSize(\_tensor)));
To :
return Uint8List.fromList(
data.asTypedList(tfliteBinding.TfLiteTensorByteSize(\_tensor)));

# Error google_mlkit_commons

- What went wrong: Execution failed for task ':google_mlkit_commons:verifyReleaseResources'. > A failure occurred while executing com.android.build.gradle.tasks.VerifyLibraryResourcesTask$Action > Android resource linking failed ERROR: D:\MyProject\MobileApps\Flutter\mobile-inout\build\google_mlkit_commons\intermediates\merged_res\release\mergeReleaseResources\values\values.xml:221: AAPT: error: resource android:attr/lStar not found.

* How to fix it
  - open C:/Users/adefa/AppData/Local/Pub/Cache/hosted/pub.dev/google_mlkit_commons-0.2.0/android/build.gradle
  - change to compileSdkVersion 34

# Error google_api_headers

- What went wrong:
  Execution failed for task ':google_api_headers:compileDebugKotlin'.
  > Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (1.8) and 'compileDebugKotlin' (21).

* How to fix it
  Modify on file C:/Users/adefa/AppData/Local/Pub/Cache/hosted/pub.dev/google_api_headers-1.6.0/android/build.gradle
  android {
  compileOptions {
  sourceCompatibility = JavaVersion.VERSION_17
  targetCompatibility = JavaVersion.VERSION_17
  }
  }
  kotlin {
  jvmToolchain(17)
  }

# Error auto_route-10.3.0 -> predictive_back_page_detector.dart:183

- What went wrong:
  D:/flutter_pub_cache/hosted/pub.dev/auto_route-10.3.0/lib/src/router/transitions/predictive_back_page_detector.dart:183:63: Error: Member not found: 'kTransitionMilliseconds'. predictive_back_page_detector.dart:183 \_kCommitMilliseconds / FadeForwardsPageTransitionsBuilder.kTransitionMilliseconds, ^^^^^^^^^^^^^^^^^^^^^^^ /D:/flutter_pub_cache/hosted/pub.dev/auto_route-10.3.0/lib/src/router/transitions/predictive_back_page_detector.dart:342:49: Error: Member not found: 'MediaQuery.heightOf'. predictive_back_page_detector.dart:342 \_getYShiftPosition(MediaQuery.heightOf(context)), ^^^^^^^^ /D:/flutter_pub_cache/hosted/pub.dev/auto_route-10.3.0/lib/src/router/transitions/predictive_back_page_detector.dart:451:43: Error: Member not found: 'MediaQuery.widthOf'. predictive_back_page_detector.dart:451 final double screenWidth = MediaQuery.widthOf(context);

* How to fix it
  - change all MediaQuery.heightOf(context) to -> MediaQuery.of(context).size.height
  - change all MediaQuery.widthOf(context) to -> MediaQuery.of(context).size.width
  - change FadeForwardsPageTransitionsBuilder.kTransitionMilliseconds -> 300

# Android Setup

- local.properties
  sdk.dir=C:\\Users\\adefa\\AppData\\Local\\Android\\Sdk
  flutter.sdk=C:\\flutter
  flutter.buildMode=debug
  flutter.versionName=1.0.0
  flutter.versionCode=1
  flutter.ndkVersion=27.0.12077973
- key.properties
  storeFile=D:\\MyProject\\MobileApps\\Flutter\\gsm_tracker.keystore
  storePassword=teknisilistrik
  keyPassword=teknisilistrik
  keyAlias=gsm_tracker

# == build project ==

- build mode debug : `flutter build apk -t lib/main_debug.dart --debug / flutter build apk -t lib/main_debug.dart`
- build mode release : `flutter build apk -t lib/main_prod.dart --release`
- build mode profiling : `flutter build apk -t lib/main_prod.dart --profile`
- build mode release split arch : `flutter build apk -t lib/main_prod.dart --release --split-per-abi`
- build mode staging release : `flutter build apk --flavor staging -t lib/main_stg.dart --release`
- build mode staging profile : `flutter build apk --flavor staging -t lib/main_stg.dart --profile`
- build mode prod release : `flutter build apk --flavor prod -t lib/main_prod.dart --release`
- build mode prod release aab : `flutter build appbundle --flavor prod -t lib/main_prod.dart --release`

# Generate rest_client with retrofit generator

flutter pub run build_runner build

# == Font ==

| Nama Font        | FontWeight        | Nilai |
| ---------------- | ----------------- | ----- |
| Thin             | `FontWeight.w100` | 100   |
| ExtraLight       | `FontWeight.w200` | 200   |
| Light            | `FontWeight.w300` | 300   |
| Regular / Normal | `FontWeight.w400` | 400   |
| Medium           | `FontWeight.w500` | 500   |
| SemiBold         | `FontWeight.w600` | 600   |
| Bold             | `FontWeight.w700` | 700   |
| ExtraBold        | `FontWeight.w800` | 800   |
| Black            | `FontWeight.w900` | 900   |

# Environtmen

`for environtment using .env (dotenv) (prod, staging)`

# Setup Module Chat

- `add manual route in router_import.gr.dart`

import 'package:chat/ui/chat_screen.dart' as \_i45;

/// generated route for
/// [_i5.ChatSreen]
class ChatScreenRoute extends \_i40.PageRouteInfo<void> {
const ChatScreenRoute({List<\_i40.PageRouteInfo>? children})
: super(ChatScreenRoute.name, initialChildren: children);

static const String name = 'ChatScreenRoute';

static \_i40.PageInfo page = \_i40.PageInfo(
name,
builder: (data) {
return const \_i45.ChatScreen();
},
);
}

- `branch project chat "chat/inout"`
- `branch project auth "chat/inout"`

# ADB Commmand in windows

- check all package : `adb shell pm list packages | Select-String twosee`
- show logcat : `adb logcat`
- show logcat spesifik : `adb logcat --pid=$(adb shell pidof dev.twosee.mobile_in_out)`
