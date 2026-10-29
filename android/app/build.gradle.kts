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
// Reuse existing Android/AGP locations without accepting another certificate.
val signingCandidates = buildList<File> {
    System.getenv("DONTEC_RELEASE_KEYSTORE")?.takeIf { it.isNotBlank() }?.let { add(File(it)) }
    val homes = listOfNotNull(
        System.getenv("ANDROID_USER_HOME"), System.getenv("ANDROID_PREFS_ROOT"),
        System.getenv("ANDROID_SDK_HOME")?.let { File(it, ".android").path },
        File(System.getProperty("user.home"), ".android").path,
        System.getenv("USERPROFILE")?.let { File(it, ".android").path }
    )
    homes.forEach { home ->
        add(File(home, "dontec-release.keystore"))
        add(File(home, "debug.keystore"))
    }
    android.signingConfigs.findByName("debug")?.storeFile?.let { add(it) }
    add(project.file("debug.keystore"))
}.distinctBy { it.absolutePath }
val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.isFile) {
    releasePropertiesFile.inputStream().use { releaseProperties.load(it) }
} else {
    // Android's standard debug credentials apply only to a matching historical key.
    // Never generate a key or accept an unrelated per-computer debug certificate.
    val historicalKey = signingCandidates
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
tasks.register("diagnoseReleaseSigning") {
    group = "verification"
    description = "Diagnóstico de rutas/certificados sin mostrar contraseñas ni modificar claves."
    doLast {
        println("Configuración explícita key.properties: " + releasePropertiesFile.isFile)
        signingCandidates.forEach { file ->
            val status = if (!file.isFile) "NO EXISTE" else runCatching {
                val fingerprint = fingerprintOf(file, "android", "androiddebugkey")
                if (fingerprint == historicalFingerprint) "COMPATIBLE" else "OTRO CERTIFICADO: $fingerprint"
            }.getOrDefault("NO LEGIBLE CON CREDENCIALES ESTÁNDAR; usar key.properties si tiene otra contraseña/alias")
            println("${file.absolutePath}: $status")
        }
        println("No se generó ni reemplazó ninguna clave.")
    }
}
val verifyReleaseSigning = tasks.register("verifyReleaseSigning") {
    doLast {
        check(!releaseProperties.isEmpty) {
            "No se encontró una clave histórica utilizable. Ejecuta diagnoseReleaseSigning desde android para conocer las rutas y el motivo. Lee APK_RELEASE.md; no generes otra clave."
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
