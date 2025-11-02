# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Flutter and Dart classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Keep Dio networking library
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }

# Keep model classes (adjust package name to your models)
-keep class com.snapdi.app.features.**.models.** { *; }

# Don't warn about missing classes
-dontwarn io.flutter.**
-dontwarn androidx.**

# Keep line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
