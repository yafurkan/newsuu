buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

//
// Legacy Flutter compatibility map for older plugins (e.g., geolocator_android 4.x)
// This exposes a "flutter" map as a project extra property so Groovy build scripts
// can access values like: compileSdkVersion flutter.compileSdkVersion
//
subprojects {
    val compileSdk = (findProperty("flutter.compileSdkVersion") as String?)?.toInt() ?: 35
    val minSdk = (findProperty("flutter.minSdkVersion") as String?)?.toInt() ?: 23
    val targetSdk = (findProperty("flutter.targetSdkVersion") as String?)?.toInt() ?: 35

    // Make available as unqualified "flutter" to Groovy build scripts
    extra["flutter"] = mapOf(
        "compileSdkVersion" to compileSdk,
        "minSdkVersion" to minSdk,
        "targetSdkVersion" to targetSdk
    )
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
