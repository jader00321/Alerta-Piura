plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // --- APPLY FIREBASE PLUGIN ---
    //id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mobile_app"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.mobile_app"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // --- ADD FIREBASE BOM & MESSAGING DEPENDENCIES ---
    //implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    //implementation("com.google.firebase:firebase-messaging")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}