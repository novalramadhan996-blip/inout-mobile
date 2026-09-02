# Keep Flutter classes from being obfuscated
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep the MainActivity class from being obfuscation
-keep class com.twosee.mobile_in_out.MainActivity { *; }

# Keep background service classes
-keep class id.flutter.flutter_background_service.** { *; }
-keep class com.yourapp.LocationForegroundService { *; }

# Keep Workmanager classes
-keep class android.arch.** { *; }
-dontwarn android.arch.**

# Maintain classes that use reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Remove unused code
-dontwarn io.flutter.**
-dontwarn com.google.firebase.**

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ML Kit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }

# Needed for GPU delegates
-keep class org.tensorflow.lite.gpu.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Keep all background process classes
-keep class com.twosee.mobile_in_out.feature.backround_process.** { *; }
-dontwarn com.twosee.mobile_in_out.feature.backround_process.**