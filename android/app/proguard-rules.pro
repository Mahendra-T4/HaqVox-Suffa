# Keep all classes in ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep audio service classes
-keep class com.ryanheise.** { *; }
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }

# Keep just_audio classes
-keep class com.ryanheise.just_audio.** { *; }

# Keep MediaBrowserServiceCompat and related classes
-keep class android.support.v4.media.session.MediaSessionCompat { *; }
-keep class android.support.v4.media.MediaBrowserCompat { *; }
-keep class android.support.v4.media.session.PlaybackStateCompat { *; }
-keep class android.support.v4.media.MediaMetadataCompat { *; }
-keep class android.support.v4.media.RatingCompat { *; }
-keep class android.support.v4.media.MediaDescriptionCompat { *; }

# Keep notification related classes
-keep class androidx.core.app.NotificationCompat$Builder { *; }
-keep class androidx.core.app.NotificationCompat$Action { *; }
-keep class androidx.core.app.NotificationCompat$MediaStyle { *; }

# Keep Kotlin Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# Keep Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** { volatile <fields>; }

# Google Mobile Ads SDK
-keep public class com.google.android.gms.ads.** { public *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-keep class com.google.android.gms.ads.identifier.** { *; }

# Keep AdMob classes
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep mediation adapters classes
-keepnames class com.google.android.gms.ads.mediation.** { *; }

# Keep Play Core library classes (used by Flutter for deferred components)
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }
-dontwarn com.google.android.play.core.**
-keepnames class com.google.ads.mediation.** { *; }

# Required for older versions of AdMob
-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

# Don't obfuscate native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Keep R class
-keep class **.R$* {
    public static <fields>;
}

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
