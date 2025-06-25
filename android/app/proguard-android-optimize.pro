#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep all public classes and methods
-keep public class * {
    public *;
}

# Keep all classes in the specified package
-keep class nl.brocast.** {
    *;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Keep all classes that are referenced in the AndroidManifest.xml
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep all classes that are referenced in the AndroidManifest.xml
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all classes that are referenced in the AndroidManifest.xml
-dontwarn android.support.**
-dontwarn android.webkit.**
-dontwarn javax.annotation.**
-dontwarn org.apache.http.**
-dontwarn org.apache.commons.codec.binary.**
-dontwarn org.json.**

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes *Annotation*,EnclosingMethod,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*AnnotationDefault*

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes SourceFile,LineNumberTable

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes *Annotation*

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes Signature

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes Deprecated

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes SourceFile

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes LineNumberTable

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes *AnnotationDefault*

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes EnclosingMethod

# Keep all classes that are referenced in the AndroidManifest.xml
-keepattributes InnerClasses
