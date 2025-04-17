plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.ecommerce.ecomerce_application"
    compileSdk = 35 // Set compileSdk to 33 (or latest available)

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ecommerce.ecomerce_application"
        minSdk = 21  // Set minSdk to 21 (or your desired minimum SDK version)
        targetSdk = 33  // Set targetSdk to 33 (or latest target version)
        versionCode = 1  // Adjust version code accordingly
        versionName = "1.0"  // Adjust version name accordingly
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
