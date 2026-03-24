import java.util.Properties

val keystoreProperties = Properties()
// key.properties가 android/app/ 또는 android/에 있을 수 있음 — 루트만 보면 파일을 못 찾아 storeFile이 null이 되어 서명 NPE 발생함
val keystorePropertiesFile =
    sequenceOf(rootProject.file("app/key.properties"), rootProject.file("key.properties"))
        .firstOrNull { it.exists() }
if (keystorePropertiesFile != null) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.seul.grooup"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.seul.grooup"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString() ?: ""
            keyPassword = keystoreProperties["keyPassword"]?.toString() ?: ""
            // storeFile은 android/ 기준 경로로 해석 (예: groo_up.jks가 android/에 있을 때 app 모듈의 file()로는 찾지 못함)
            storeFile =
                keystoreProperties["storeFile"]?.toString()?.let { path -> rootProject.file(path) }
            storePassword = keystoreProperties["storePassword"]?.toString() ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}