# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Your app package
-keep class com.ivyis.pawlli.** { *; }

# OpenStreetMap & Networking
-keep class org.osmdroid.** { *; }
-keep class com.mapbox.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Geocoder and Android Location
-keep class geocoder.** { *; }
-keep class android.location.** { *; }

# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Required annotations
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep Google Play Core (used by FlutterPlayStoreSplitApplication)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Keep all annotations
-keepattributes *Annotation*
# Geolocator plugin (location handling)
-keep class com.baseflow.geolocator.** { *; }
-keep class geolocator.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Needed for fused location provider
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.common.ConnectionResult { *; }
-keep class com.google.android.gms.location.LocationRequest { *; }

# Prevent warnings and keep internals used by plugins
-dontwarn com.google.android.gms.**
-dontwarn com.baseflow.**

# permission_handler plugin
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**
