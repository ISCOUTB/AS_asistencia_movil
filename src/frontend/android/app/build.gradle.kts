import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties more safely
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    // Fail with a clear message about where to create the file
    throw GradleException(
        "key.properties not found at ${keystorePropertiesFile.path}. " +
        "Create the file in the project root with storePassword, keyPassword and keyAlias (see sample key.properties)."
    )
}

fun prop(name: String): String =
    keystoreProperties.getProperty(name)
        ?: throw GradleException("Missing '$name' in key.properties")

android {
    namespace = "com.example.asistenciamovil"

    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Kotlin jvm target
    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.asistenciamovil"
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = 1
        versionName = "1.0"

        manifestPlaceholders["appAuthRedirectScheme"] = "msauth"
    }

    signingConfigs {
        create("release") {
            // Verify this path exists relative to android/ directory
            storeFile = rootProject.file("../assets/nuevo_keystore.jks")
            storePassword = prop("storePassword")
            keyAlias = prop("keyAlias")
            keyPassword = prop("keyPassword")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release") // optional but OK for local tests
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}