pluginManagement {
    // Basitleştirilmiş Flutter SDK yolu çözümlemesi - CI/CD uyumlu
    val flutterSdkPath: String = run {
        // 1) local.properties dosyasından oku (CI'da oluşturulan)
        val localPropsFile = file("local.properties")
        if (localPropsFile.exists()) {
            val properties = java.util.Properties()
            localPropsFile.inputStream().use { properties.load(it) }
            val sdkPath = properties.getProperty("flutter.sdk")
            if (sdkPath != null) return@run sdkPath
        }
        
        // 2) Ortam değişkenlerinden oku (GitHub Actions)
        System.getenv("FLUTTER_HOME")
            ?: System.getenv("FLUTTER_ROOT")
            ?: throw GradleException("Flutter SDK path not found. Please ensure local.properties contains flutter.sdk or set FLUTTER_HOME environment variable.")
    }

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
