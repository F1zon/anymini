plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Путь к ключу подписи читается из переменных окружения, чтобы пароль не попадал в git.
// Если переменные не заданы, используется отладочный ключ (удобно для локальной сборки).
val useReleaseSigning =
    System.getenv("ANIMINI_KEYSTORE") != null && System.getenv("ANIMINI_KEYSTORE_PASSWORD") != null
val keystorePath = System.getenv("ANIMINI_KEYSTORE")
val keystorePass = System.getenv("ANIMINI_KEYSTORE_PASSWORD")

android {
    namespace = "com.anymini.anymini"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.anymini.anymini"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (useReleaseSigning) {
                signingConfigs.create("release") {
                    keyAlias = "anymini"
                    keyPassword = keystorePass
                    storeFile = file(keystorePath)
                    storePassword = keystorePass
                }
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
