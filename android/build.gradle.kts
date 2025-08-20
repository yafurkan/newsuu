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

// Legacy "flutter" map'ini çok erken aşamada (tüm projeler ve root için) yayınla.
// Eski eklentiler (ör. geolocator_android 4.x) android { compileSdkVersion flutter.compileSdkVersion } beklentisini bu sayede karşılar.
val legacyCompileSdk = (findProperty("flutter.compileSdkVersion") as String?)?.toInt() ?: 35
val legacyMinSdk = (findProperty("flutter.minSdkVersion") as String?)?.toInt() ?: 23
val legacyTargetSdk = (findProperty("flutter.targetSdkVersion") as String?)?.toInt() ?: 35

// Root projeye koy
extensions.extraProperties.set(
    "flutter",
    mapOf(
        "compileSdkVersion" to legacyCompileSdk,
        "minSdkVersion" to legacyMinSdk,
        "targetSdkVersion" to legacyTargetSdk
    )
)

// beforeProject bloğu KTS tarafında Closure beklediği için CI'da derleme hatasına yol açıyordu.
// Root/allprojects/subprojects seviyelerinde zaten 'flutter' map'i set edildiği için bu blok gereksiz.
// Bu yüzden kaldırıldı.

// Ek olarak allprojects içinde de set et (bazı çözümleme senaryolarında gerekli olabilir)
allprojects {
    extensions.extraProperties.set(
        "flutter",
        mapOf(
            "compileSdkVersion" to legacyCompileSdk,
            "minSdkVersion" to legacyMinSdk,
            "targetSdkVersion" to legacyTargetSdk
        )
    )
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
