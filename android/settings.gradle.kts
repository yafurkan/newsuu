pluginManagement {
    // Flutter SDK yolunu bulmak için esnek çözüm:
    // 1) Gradle property: flutter.sdk
    // 2) local.properties içindeki flutter.sdk (varsa)
    // 3) Ortam değişkenleri: FLUTTER_HOME veya FLUTTER_ROOT (GitHub Actions/subosito/flutter-action bunları set eder)
    val flutterSdkPath: String = run {
        // 1) gradle.properties veya -Pflutter.sdk ile verilen değer
        val fromGradleProp = providers.gradleProperty("flutter.sdk").orNull
        if (fromGradleProp != null) return@run fromGradleProp

        // 2) local.properties (opsiyonel)
        val propsFile = file("local.properties")
        if (propsFile.exists()) {
            val properties = java.util.Properties()
            propsFile.inputStream().use { properties.load(it) }
            properties.getProperty("flutter.sdk")
        } else null
    } ?: System.getenv("FLUTTER_HOME")
      ?: System.getenv("FLUTTER_ROOT")
      ?: throw GradleException("Flutter SDK bulunamadı. local.properties içinde flutter.sdk belirtin ya da FLUTTER_HOME/FLUTTER_ROOT ortam değişkenini ayarlayın.")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
