import java.util.Properties
import java.io.File
import java.security.KeyStore
import java.security.MessageDigest

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties has precedence. Only the original certificate may be reused.
val historicalFingerprint = "cf604910dddfe0bc4c885faa1b87c369585d6b19228332a190f9e6f153ce5f3b"
fun fingerprintOf(file: File, password: String, alias: String): String {
    val store = KeyStore.getInstance(file, password.toCharArray())
    val certificate = store.getCertificate(alias) ?: error("No se encontró el alias de firma.")
    return MessageDigest.getInstance("SHA-256").digest(certificate.encoded)
        .joinToString("") { "%02x".format(it.toInt() and 0xff) }
}
val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.isFile) {
    releasePropertiesFile.inputStream().use { releaseProperties.load(it) }
} else {
    // Android's standard debug credentials apply only to a matching historical key.
    // Never generate a key or accept an unrelated per-computer debug certificate.
    val androidHome = File(System.getProperty("user.home"), ".android")
    val historicalKey = listOf("dontec-release.keystore", "debug.keystore")
        .map { File(androidHome, it) }
        .firstOrNull { file -> file.isFile && runCatching {
            fingerprintOf(file, "android", "androiddebugkey") == historicalFingerprint
        }.getOrDefault(false) }
    if (historicalKey != null) {
        releaseProperties.setProperty("storeFile", historicalKey.absolutePath)
        releaseProperties.setProperty("storePassword", "android")
        releaseProperties.setProperty("keyAlias", "androiddebugkey")
        releaseProperties.setProperty("keyPassword", "android")
    }
}
val verifyReleaseSigning = tasks.register("verifyReleaseSigning") {
    doLast {
        check(!releaseProperties.isEmpty) {
            "No se encontró la firma histórica. Lee AGENTS.md y APK_RELEASE.md. Conserva la clave original del servidor o configura android/key.properties; no generes otra clave."
        }
        listOf("storeFile", "storePassword", "keyAlias", "keyPassword").forEach {
            check(!releaseProperties.getProperty(it).isNullOrBlank()) { "Falta $it en android/key.properties" }
        }
        val keyFile = rootProject.file(releaseProperties.getProperty("storeFile"))
        val store = KeyStore.getInstance(keyFile, releaseProperties.getProperty("storePassword").toCharArray())
        val certificate = store.getCertificate(releaseProperties.getProperty("keyAlias"))
        check(certificate != null) { "No se encontró el certificado de publicación." }
        val fingerprint = MessageDigest.getInstance("SHA-256")
            .digest(certificate.encoded).joinToString("") { "%02x".format(it.toInt() and 0xff) }
        check(fingerprint == historicalFingerprint) {
            "Firma incorrecta: debe utilizarse la clave histórica del servidor. Consulta APK_RELEASE.md."
        }
    }
}
tasks.configureEach {
    if (name == "preReleaseBuild") dependsOn(verifyReleaseSigning)
}

android {
    namespace = "com.example.donluis_forms"
    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.donluis_forms"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            releaseProperties.getProperty("storeFile")?.let { storeFile = rootProject.file(it) }
            storePassword = releaseProperties.getProperty("storePassword")
            keyAlias = releaseProperties.getProperty("keyAlias")
            keyPassword = releaseProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
