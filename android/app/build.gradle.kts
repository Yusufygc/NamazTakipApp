import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release imzası: android/key.properties (depoya girmez, bkz. android/.gitignore).
// Gerekli alanlar: storeFile, storePassword, keyAlias, keyPassword.
val keystoreProps = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProps.getProperty("storeFile") != null
val allowDebugSigning = System.getenv("ALLOW_DEBUG_SIGNING") == "1"

// Anahtarsız release derlemesi, debug imzalı bir sürümün yanlışlıkla üretilmesini
// önlemek için durdurulur. Yan yükleme testi için ALLOW_DEBUG_SIGNING=1 verilir.
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any {
        it.name.matches(Regex("(assemble|bundle|package)Release"))
    }
    if (buildsRelease && !hasReleaseKey && !allowDebugSigning) {
        throw GradleException(
            "Release imza anahtarı yok: android/key.properties bulunamadı. " +
                "Mağaza sürümü için anahtar üretin (docs/wiki/derleme-ve-yayin.md). " +
                "Yalnızca yan yükleme testi için ALLOW_DEBUG_SIGNING=1 ile yeniden deneyin."
        )
    }
}

android {
    namespace = "com.namaztakip.namaz_takip"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications zamanlanmış bildirimler için gerektirir.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.namaztakip.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKey) {
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // Buraya yalnızca ALLOW_DEBUG_SIGNING=1 ile gelinir (yukarıdaki kapı).
                logger.warn("UYARI: release debug anahtarıyla imzalanıyor; mağazaya yüklenemez.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
