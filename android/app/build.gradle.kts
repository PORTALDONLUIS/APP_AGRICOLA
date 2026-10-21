import java.util.Properties
import java.security.KeyStore
import java.security.MessageDigest

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Local, ignored by Git. Never fall back to this computer's debug key.
val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.isFile) {
    releasePropertiesFile.inputStream().use { releaseProperties.load(it) }
}
val verifyReleaseSigning = tasks.register("verifyReleaseSigning") {
    doLast {
        check(releasePropertiesFile.isFile) {
            "Falta android/key.properties. Consulta APK_RELEASE.md; no se permite publicar con firma debug local."
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
        check(fingerprint == "cf604910dddfe0bc4c885faa1b87c369585d6b19228332a190f9e6f153ce5f3b") {
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
