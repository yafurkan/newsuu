plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // Flutter plugin'i apply etmeden önce kontrol edelim
    id("dev.flutter.flutter-gradle-plugin")
}

// Flutter SDK yolunu manuel olarak belirtelim
val flutterRoot: String = run {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        val properties = java.util.Properties()
        localPropertiesFile.inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_HOME") ?: ""
    } else {
        System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_HOME") ?: ""
    }
}

android {
    namespace = "com.sutakip.app2025"
    compileSdk = 35
    ndkVersion = "29.0.13599879"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sutakip.app2025"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = "su-takip-key"
            keyPassword = "123987*qa"
            storeFile = file("su-takip-release-key.jks")
            storePassword = "123987*qa"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
}

// Flutter configuration
flutter {
    source = "../.."
    // CI ortamında bu değerler local.properties'den okunacak
}
